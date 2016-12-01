# Learn more about module testing here:
# https://docs.puppetlabs.com/guides/tests_smoke.html
# invoke with no defaults just to see what happens to the run.properties file.
class {'::pingfederate::config':
  install_dir                         => '/tmp/testfiles',
  admin_https_port                    => 1234,
  admin_hostname                      => 'foobar',
  console_bind_address                => '0.0.0.0',
  console_title                       => 'test federate',
  console_session_timeout             => 60,
  console_login_mode                  => 'single',
  console_authentication              => 'ldap',
  admin_api_authentication            => 'native',
  http_port                           => 8080,
  https_port                          => 8443,
  secondary_https_port                => 9443,
  engine_bind_address                 => '0.0.0.0',
  monitor_bind_address                => '0.0.0.0',
  log_event_detail                    => true,
  heartbeat_system_monitoring         => true,
  operational_mode                    => 'CLUSTERED_ENGINE',
  cluster_node_index                  => 14,
  cluster_auth_pwd                    => 'foobar',
  cluster_encrypt                     => true,
  cluster_bind_address                => '127.0.0.1',
  cluster_bind_port                   => 8600,
  cluster_failure_detection_bind_port => 8700,
  cluster_transport_protocol          => 'tcp',
  cluster_mcast_group_address         => '239.16.96.99',
  cluster_mcast_group_port            => 8601,
  cluster_tcp_discovery_initial_hosts => 'hosta[7777], hostb[9999]',
  pf_cluster_diagnostics_enabled      => true,
  pf_cluster_diagnostics_addr         => '224.0.75.99',
  pf_cluster_diagnostics_port         => 8500
  }
