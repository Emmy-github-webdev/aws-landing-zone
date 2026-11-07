
locals {
  firewall_home_net = var.firewall_home_net_cidrs

  firewall_allow_rules = concat(
    [
      for port in var.firewall_allowed_tcp_ports :
      "pass tcp $HOME_NET any -> any ${port} (sid:${1000 + port}; rev:1;)"
    ],
    [
      for port in var.firewall_allowed_udp_ports :
      "pass udp $HOME_NET any -> any ${port} (sid:${2000 + port}; rev:1;)"
    ],
    [
      "pass tcp $HOME_NET any -> any 53 (sid:3001; rev:1;)",
      "drop ip $HOME_NET any -> any any (sid:3002; rev:1;)"
    ]
  )

  firewall_rules_string = join(
    "\n",
    local.firewall_allow_rules
  )
}

resource "aws_networkfirewall_rule_group" "egress" {
  provider = aws.infrastructure

  count = var.enable_centralized_egress ? 1 : 0

  capacity = 100
  name     = "lz-egress-allow-rules"
  type     = "STATEFUL"

  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"

        ip_set {
          definition = local.firewall_home_net
        }
      }
    }

    rules_source {
      rules_string = local.firewall_rules_string
    }

    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }

  tags = local.common_tags
}

resource "aws_networkfirewall_firewall_policy" "egress" {
  provider = aws.infrastructure

  count = var.enable_centralized_egress ? 1 : 0

  name = "lz-central-egress-policy"

  firewall_policy {
    stateless_default_actions = [
      "aws:forward_to_sfe"
    ]

    stateless_fragment_default_actions = [
      "aws:forward_to_sfe"
    ]

    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }

    stateful_rule_group_reference {
      priority     = 100
      resource_arn = aws_networkfirewall_rule_group.egress[0].arn
    }

    stateful_default_actions = [
      "aws:drop_strict"
    ]
  }

  tags = local.common_tags
}