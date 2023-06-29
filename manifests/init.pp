#
# @summary set up promtotwilio
#
# @param sid
#   Twilio account SID
# @param token
#   Twilio Auth Token
# @param sender
#   Phone number managed by Twilio (friendly name)
# @param receiver
#   Phone number of receiver (optional parameter, representing default receiver)
# @param port
#   Port promtotwilio listens on
# @param url
#   The URL from which to download promtotwilio.
# @param source
#   Source of the promtotwilio binary. Could be a Puppet fileserver path or a
#   local path.
#
class promtotwilio (
  String                    $sid,
  String                    $token,
  String                    $sender,
  String                    $receiver,
  String                    $source,
  Stdlib::Port              $port,
  Optional[Stdlib::HTTPUrl] $url,
) {
  if $url {
    archive { $source:
      source   => $url,
      # GitHub does redirect, so use wget instead of the default (curl)
      provider => 'wget',
      before   => File['promtotwilio'],
    }
  }

  $conf_params = { 'sid'      => $sid,
    'token'    => $token,
    'sender'   => $sender,
    'receiver' => $receiver,
  'port'     => $port, }

  file {
    default:
      ensure => 'file',
      owner  => 'root',
      group  => 'root',
      notify => Service['promtotwilio'],
      before => Service['promtotwilio'],
      ;
    ['promtotwilio']:
      name   => '/usr/local/bin/promtotwilio',
      source => $source,
      mode   => '0755',
      ;
    ['promtotwilio.service']:
      name    => '/etc/systemd/system/promtotwilio.service',
      content => template('promtotwilio/promtotwilio.service.erb'),
      notify  => [Exec['promtotwilio systemctl daemon-reload'], Service['promtotwilio']],
      mode    => '0644',
      ;
    ['promtotwilio.conf']:
      name    => '/etc/promtotwilio.conf',
      content => epp('promtotwilio/promtotwilio.conf.epp', $conf_params),
      mode    => '0600',
      ;
  }

  exec { 'promtotwilio systemctl daemon-reload':
    command     => 'systemctl daemon-reload',
    path        => ['/bin', '/usr/bin'],
    refreshonly => true,
    before      => Service['promtotwilio'],
  }

  service { 'promtotwilio':
    ensure => 'running',
    enable => true,
  }
}
