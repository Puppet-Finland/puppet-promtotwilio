# promtotwilio

This Puppet module helps manage
[promtotwilio](https://github.com/Swatto/promtotwilio), which is "a simple and
stupid program that will receive webhooks from Prometheus to send them as text
message (using Twilio) with the summary of the alert."

## Setup

You need a Twilio account and before using this module should test that
you can send SMS manually, e.g. with curl. 

## Usage

Once the prerequisites of this module are taken care of, its usage is fairly
straightforward:

```
class { 'promtotwilio':
  sid      => 'your-twilio-account-sid',
  token    => 'your-twilio-auth-token',
  sender   => 'your-twilio-phone-number',
  receiver => 'phone-number-to-send-sms-to',
  port     => 9191,
}
```

You can download promtotwilio from a custom URL using the *url* parameter,
or you can place a copy of *promtotwilio* on your Puppet fileserver. The
*source* parameter defines where the Puppet File resource gets the binary
from.

The default listen port, 9090, may conflict with Prometheus. If you're using
unpatched version of promtotwilio then port 9090 is your only choice.

To have alerts sent via SMS you need to configure Alertmanager routes in
*/etc/alertmanager/alertmanager.conf*. Here's a simplistic example where alerts
of *critical* severity get routed as SMS; other alerts will use default route
(e.g. email).

```
route:
  --- snip ---
  routes:
  - match:
      severity: critical
    receiver: sms
receivers:
- name: sms
  webhook_configs:
  - url: http://127.0.0.1:9191/send
```
