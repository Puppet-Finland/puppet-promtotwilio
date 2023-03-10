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
#
class promtotwilio (
  String       $sid,
  String       $token,
  String       $sender,
  String       $receiver,
  Stdlib::Port $port,
) {
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
      source => 'puppet:///files/promtotwilio', # lint:ignore:puppet_url_without_modules
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
