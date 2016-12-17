# Class pingfederate::oauth_jdbc
#
# Configure the oauth JDBC service only if oauth_jdbc_type is set.
#
# Unfortunately the 'clean' way to do this is to invoke the pf-admin-api to add the database connector
# and then edit two XML files, adding the JNDI-NAME to one of them, which requires restarting the
# service -- TWICE -- once to install the required jar file and again after editing the XML files.
# The 'dirty' way would be to just edit the datastore XML file that gets created by the pf-admin-api,
# but who knows what other things that API might do?
#
# The --json file is input to the pf-admin-api POST to define a new JDBC datastore.
# If it appears for the first time (or changes), that triggers invoking the API.
# The --response file is the response from the POST.
# It is also used on subsequent invocations to get the 'id' in order to do a GET/PUT
# to update the existing resource (e.g. for a password change).
#
# Note that the API tries to connect to the database to confirm it is available. This is why the JAR
# has to be in the classpath and why the server has to be restarted the first time.
#
class pingfederate::oauth_jdbc inherits ::pingfederate {
  if $::pingfederate::oauth_jdbc_type {
    $ds = "${::pingfederate::install_dir}/local/etc/dataStores.json"
    if $::pingfederate::oauth_jdbc_package_ensure {
      ensure_packages($::pingfederate::o_pkgs,{'ensure' => $::pingfederate::oauth_jdbc_package_ensure})
    }
    # make sure the jar file is there and, if newly installed, bounce the server.
    file { "${::pingfederate::install_dir}/server/default/lib/${::pingfederate::o_jar}":
      ensure => 'present',
      source => "${::pingfederate::o_jar_dir}/${::pingfederate::o_jar}",
      links  => 'follow',
      owner  => $::pingfederate::owner,
      group  => $::pingfederate::group,
    } ~>
    exec {'restart after adding jar file to classpath':
      command     => "/sbin/service ${::pingfederate::service_name} restart",
      refreshonly => true,
    } ~>
    Exec['pf-admin-api version'] ~> # wait for server restart
    file {$ds:
      ensure   => 'present',
      mode     => 'u=r,go=',
      owner    => $::pingfederate::owner,
      group    => $::pingfederate::group,
      content  => template('pingfederate/dataStores.json.erb'),
    } ~> 
    if $::pingfederate::o_cmd {
      exec {"oauth_jdbc DDL ${::pingfederate::o_url}":
        command => $::pingfederate::o_cmd,
        refreshonly => true,
        user        => $::pingfederate::owner,
        logoutput   => true,
      }
    } ~>
    exec {'pf-admin-api POST dataStores':
      command     => "${::pingfederate::install_dir}/local/bin/pf-admin-api -m POST -j ${ds} -r ${ds}.out dataStores || rm -f ${ds}",
      refreshonly => true,
      user        =>  $::pingfederate::owner,
      logoutput   => true,
    } ~>
    exec {'oauth_jdbc_augeas':
      command     => "${::pingfederate::install_dir}/local/bin/oauth_jdbc_augeas",
      refreshonly => true,
      user        =>  $::pingfederate::owner,
      logoutput   => true,
    }
  }
}
