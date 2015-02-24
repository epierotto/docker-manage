#! /usr/bin/perl -w
# yum install -y perl-JSON.noarch perl-Redis.noarch perl-MIME-Types.noarch perl-libwww-perl.noarch
#
use LWP::UserAgent;
use Redis;
use JSON;
use MIME::Base64 qw( decode_base64 );
use Data::Dumper; # For debbuging
use Getopt::Long;
use strict;

# Needed options to perform the
our @options = ("hostname","port","service");
our $usage = "Usage: $0 [-d|--debug] -h <hostname|ip-address> -p <port> -s <service-name>\nExample: $0 -h redis1 -p 6379 -s redis-test\n";
our %opts;

sub CheckParameters{
	GetOptions(
		\%opts,
		'hostname|h=s',
		'port|p=s',
		'service|s=s',
		'help|?',
		'debug'
	);
		
	foreach (@_){
		print "ERROR Missing argument <$_> \n$usage" and exit 1 unless exists ($opts{$_});
	}

	print $usage and exit 0 if ($opts{'help'});

	print "<<<<DEBUG MODE>>>>\n\nARGUMENTS:",Dumper (\%opts),"\n" if ($opts{'debug'});

}

sub GET{

	# define a URL
	my ($url) = @_;

	# create UserAgent object
	my $ua = LWP::UserAgent->new;

	# timeout:
	$ua->timeout(15);
	
	# set custom HTTP request header fields
        my $request = HTTP::Request->new(GET => $url);
        $request->header('content-type' => 'application/json');

	# proceed the request:
	$request->url($url);

	my $response = $ua->request($request) or die "GET ERROR: $@\n" and exit 1;
	
	# responses:
	my $data;
	if ($response->is_success) {
	    my $message = $response->decoded_content;
	    $data = JSON->new->utf8->decode($message) unless ($message eq "");
	    print "GET RESPONSE:",Dumper (\$data) if ($opts{'debug'});
	}
	else {
	    print "HTTP GET error code: ", $response->code, "\n";
	    print "HTTP GET error message: ", $response->message, "\n";
	    undef $data;
	}
	
	return $data;
}


sub PUT{

	# define a URL
        my ($url, $put_data) = @_;
	print "PUT DATA: URL=> $url\tDATA=> $put_data\n" if ($opts{'debug'});

        # create UserAgent object
        my $ua = LWP::UserAgent->new;

        # timeout:
        $ua->timeout(15);

        # set custom HTTP request header fields
        my $request = HTTP::Request->new(PUT => $url);
        $request->header('content-type' => 'application/json');

	# add PUT data to HTTP request body
	$request->content($put_data);
        $request->url($url);

        my $response = $ua->request($request) or die "GET ERROR: $@\n" and exit 1;
	
	my $data;
	if ($response->is_success) {
	    my $message = $response->decoded_content;
	    if (($message eq 'true') or ($message eq 'false')){
		print "PUT RESPONSE: $message\n" if ($opts{'debug'});	
		return $message;
	    }
	    elsif ($message ne ""){
		$data = JSON->new->utf8->decode($message);	
		print "PUT RESPONSE:",Dumper (\$data) if ($opts{'debug'});
	    }
	    
	    
	}
	else {
	    print "HTTP POST error code: ", $response->code, "\n";
	    print "HTTP POST error message: ", $response->message, "\n";
	}
	return $data;
}

sub GetRedisInfo{
	my ($host,$port) = @_;
	my $r;
	my %info;
	eval {$r = Redis->new( server => "$host:$port", debug => 0 )};
	if ($@){
		$info{'FAIL'} = "TRUE";
	}
	else{
		$r->connect;
		%info = %{$r->info('Replication')};
		$info{'FAIL'} = "FALSE";
		$r->quit;
	}
	print "REDIS INFO:",Dumper (\%info) if ($opts{'debug'});
	return %info;

}

sub CheckRedis{
	my %info = @_;
	my $status = 0;
	my @output;
	if ("$info{'role'}" eq "master"){

		push (@output, ("master","connected_slaves $info{'connected_slaves'}",));

		for( my $i = 0; $i < $info{'connected_slaves'}; $i++) {
			my @slaves = split(",",$info{"slave$i"});
			my %hash;
			foreach my $slave (@slaves){
				my @s_info = split("=",$slave);
				$hash{$s_info[0]} = "$s_info[1]"; 
				print "HASH:",Dumper (\%hash) if ($opts{'debug'});

			}	
			$status = 1 if ($hash{'state'} ne 'online');	
			push (@output, ("slave$i $hash{'ip'}:$hash{'port'} $hash{'state'}" ));
	 	}

	}
	elsif ("$info{'role'}" eq "slave"){
        	push (@output, ("slave_of $info{'master_host'}:$info{'master_port'}","link_status $info{'master_link_status'}","master_last_io_seconds_ago $info{'master_last_io_seconds_ago'}","slave_read_only $info{'slave_read_only'}","connected_slaves $info{'connected_slaves'}"));
		
		$status = 2 if ($info{'master_link_status'} ne "up");	

	}
	
	print "STATUS= $status\nREDIS CHECK:",Dumper (\@output) if ($opts{'debug'});

	my $out = join(', ', @output);

	return ($status,$out);

}

sub SetRedisSlaveof{
	my ($host,$port,$master) = @_;
	my $r = Redis->new( server => "$host:$port", debug => 0 );
	$r->connect;
	$r->slaveof($master, $port);
	print "NOW SLAVE OF: $master\n" if ($opts{'debug'});
	$r->quit;
}

sub SetRedisNoSlave{
	my ($host,$port) = @_;
	my $r = Redis->new( server => "$host:$port", debug => 0 );
	$r->connect;
	#$r->set('slave' => 'value');
	$r->slaveof('NO','ONE');
	print "NOW SLAVE OF NO ONE\n" if ($opts{'debug'});
	$r->quit;
}


sub CheckSessionLock{
	my ($hostname,$service) = @_;
	my @session = GET("http://$hostname:8500/v1/kv/$service");
	my %session_info = ('Value' => undef, 'Session' => undef, 'Key' => undef);
	if ($session[0][0]){
		%session_info = %{$session[0][0]};
	}
	print "SESSION INFO:",Dumper (\%session_info) if ($opts{'debug'});
	return %session_info;
}

sub CreateSession{
	my ($hostname,$service) = @_;
	my $json = "{\"Name\": \"$service\"}";
	my %session = %{PUT("http://$hostname:8500/v1/session/create", "$json")};
	print "SESSION CREATED:",Dumper (\%session) if ($opts{'debug'});
	my $session_id;
	if ($session{'ID'}){
		$session_id = $session{'ID'};
		print "SESSION ID: $session_id\n" if ($opts{'debug'});
	}
	
	return $session_id;
}

sub AcquireSession{
	my ($hostname,$service,$session_id,$key_value) = @_;
	
        my $session_lock = PUT("http://$hostname:8500/v1/kv/$service?acquire=$session_id", "$key_value");
        print "SESSION LOCK: $session_lock\n" if ($opts{'debug'});
	return $session_lock;
}

sub ReleaseSession{
	my ($hostname,$service,$session_id) = @_;
        my $session_lock = PUT("http://$hostname:8500/v1/kv/$service?release=$session_id", "");
        print "SESSION RELEASED: $session_lock\n" if ($opts{'debug'});
	return $session_lock;
}
 
sub GetServiceNodes{
	my ($hostname,$service) = @_;
	my @service_query = GET("http://$hostname:8500/v1/catalog/service/$service");
        my @service_nodes;

	foreach my $nodes (@{$service_query[0]}){
		push (@service_nodes, ${$nodes}{'Node'});
	}

	print "NODES:",Dumper (\@service_nodes) if ($opts{'debug'});
        return @service_nodes;
}

sub ServiceRegistation{
	my ($hostname,$service,$port) = @_;
	#my $json = "{\"Name\": \"$service\", \"Port\": $port, \"Check\": {\"Script\": \"/home/vagrant/redis-cluster.pl -h $hostname -p $port -s $service\",\"Interval\": \"5s\"}}";
	my $json = "{\"Name\": \"$service\", \"Port\": $port}";
	# Service Register
	my $registration = PUT("http://$hostname:8500/v1/agent/service/register", "$json");
	
	print "SERVICE REGISTERED:",Dumper (\$registration) if ($opts{'debug'});
	
	return $registration;
}

sub ServiceDeregistation{
	my ($hostname,$node,$service) = @_;
	my $json = "{\"Node\": \"$node\", \"ServiceID\": \"$service\"}";

	# Service Deregister
	my $deregistration = PUT("http://$hostname:8500/v1/catalog/deregister", "$json");
	
	# Deregister service
	print "SERVICE ".$service." DEREGISTERED:",Dumper (\$deregistration) if ($opts{'debug'});
	
	return $deregistration;
}

sub ServiceLocalDeregistation{
	my ($hostname,$service) = @_;
	my $deregistration = GET("http://$hostname:8500/v1/agent/service/deregister/$service");
	print "SERVICE ".$service." DEREGISTERED:",Dumper (\$deregistration) if ($opts{'debug'});
	return $deregistration;
}

sub GetNodeSessions{
	my ($hostname,$node_name) = @_;
	my @session_destroy = @{GET(" http://$hostname:8500/v1/session/node/$node_name")};
	print "NODE SESSIONS:",Dumper (\@session_destroy) if ($opts{'debug'});
	return @session_destroy;
}

sub DestroySession{
	my ($hostname,$session_id) = @_;
	my $session_destroy = PUT("http://$hostname:8500/v1/session/destroy/$session_id","");
	print "SESSION DESTROYED:",Dumper (\$session_destroy) if ($opts{'debug'});
	return $session_destroy;
}

sub GetNodeName{
	my ($hostname) = @_;
	my %node_info = %{GET("http://$hostname:8500/v1/agent/self")};
        my $node_name = $node_info{'Config'}{'NodeName'};
        print "NODE NAME: $node_name\n"if ($opts{'debug'});
        return $node_name;
}

sub GetNodeServices{
	my ($hostname) = @_;
	my %node_services = %{GET("http://$hostname:8500/v1/agent/services")};
	print "NODE SERVICES:" ,Dumper (\%node_services) if ($opts{'debug'});
        return %node_services;
}

# MAIN

&CheckParameters(@options);

# Get the session info from a given service
my %session = CheckSessionLock($opts{'hostname'},$opts{'service'});

# Get the redis info from a given host
my %redis_info = GetRedisInfo("$opts{'hostname'}","$opts{'port'}");


# Get the Consul node name
my $node_name = GetNodeName("$opts{'hostname'}");

# Get the services declared on the node
my %node_services = GetNodeServices("$opts{'hostname'}");

my $master_kv;

# Try to connect to the given redis instance
if ($redis_info{'FAIL'} eq "TRUE"){
	
	# Check if the session and the key_value are set
	if ($session{'Value'} and $session{'Session'}){
		$master_kv = decode_base64($session{'Value'});
		
		# Release the session if you are the master redis
		ReleaseSession($opts{'hostname'},$opts{'service'},$session{'Session'}) if ("$opts{'hostname'}" eq "$master_kv");

		# Destroy unused session
                DestroySession($opts{'hostname'},$session{'Session'}) if ("$opts{'hostname'}" eq "$master_kv");	

		if ($node_services{"$opts{'service'}"}){
#                        ServiceLocalDeregistation($opts{'hostname'},$opts{'service'});
                }
	}
	exit 2;
}

# Get the array of nodes running a given service
my @service_nodes = GetServiceNodes($opts{'hostname'},$opts{'service'});

#exit 0;

if ($session{'Session'}){

	$master_kv = decode_base64($session{'Value'});
	print "MASTER KV: $master_kv\n" if ($opts{'debug'});

	if ($redis_info{'role'} eq 'slave'){

		if ($redis_info{'master_host'} ne $master_kv){
			SetRedisSlaveof("$opts{'hostname'}","$opts{'port'}","$master_kv");	
			print "NOW SLAVE OF: $master_kv\n" if ($opts{'debug'});
		}
		else{
			print "SLAVE OF: $master_kv\n" if ($opts{'debug'});
		}
		
		# Deregister the service if declared
		if ($node_services{"$opts{'service'}"}){
			ServiceLocalDeregistation($opts{'hostname'},$opts{'service'});
		}
		

	
	}
	elsif ($redis_info{'role'} eq 'master'){
		
		if($master_kv ne $opts{'hostname'}){

			# Set slaveof master kv
			SetRedisSlaveof("$opts{'hostname'}","$opts{'port'}","$master_kv");
			
			# Deregister the service if declared
			if ($node_services{"$opts{'service'}"}){
                        	ServiceLocalDeregistation($opts{'hostname'},$opts{'service'});
                	}

			print "NOW SLAVE OF: $master_kv\n" if ($opts{'debug'});
		}
		else{
			print "IM THE MASTER!!: $master_kv\n" if ($opts{'debug'});
			
			# Register the service if not defined
			if (!$node_services{"$opts{'service'}"}){
				ServiceRegistation($opts{'hostname'},$opts{'service'},$opts{'port'});
                	}

		}
	}
}
else{
	# Create the session ID
	my $session_id = CreateSession($opts{'hostname'},$opts{'service'});

	# Try to lock the session and set the Key=Value with the master ip address
	my $session_lock = AcquireSession($opts{'hostname'},$opts{'service'},$session_id,"$opts{'hostname'}");

	# If the session got locked
	if ($session_lock eq "true"){

		# Set Redis as Master
		SetRedisNoSlave("$opts{'hostname'}","$opts{'port'}");	

		# Register the Consul service
		ServiceRegistation($opts{'hostname'},$opts{'service'},$opts{'port'});	

		# Deregister the service from all the other nodes but the the local agent
		foreach my $node (@service_nodes){
			ServiceDeregistation($opts{'hostname'},$node,$opts{'service'}) unless ($node eq $node_name);
		}
	}
	else{
		# Destroy unused session
		DestroySession($opts{'hostname'},$session_id);
			
	}
}

my %redis_inf = GetRedisInfo("$opts{'hostname'}","$opts{'port'}");

my ($status,$output) = CheckRedis(%redis_inf);

print "STATUS: $status\nCHECK: $output\n" if ($opts{'debug'});
print "$output";
exit $status;
