defmodule FzWall.CLI.Live do
  @moduledoc """
  A low-level module for interacting with the iptables CLI.

  Rules operate on the iptables forward chain to deny outgoing packets to
  specified IP addresses, ports, and protocols from FireZone device IPs.

  Note that iptables chains and rules are mutually exclusive between IPv4 and IPv6.
  """

  import FzCommon.CLI

  @setup_chain_cmd "iptables -N firezone && iptables6 -N firezone"
  @teardown_chain_cmd "iptables -F firezone &&\
                       iptables -X firezone &&\
                       iptables6 -F firezone &&\
                       iptables6 -X firezone"

  @doc """
  Sets up the FireZone iptables chain.
  """
  def setup do
    exec!(@setup_chain_cmd)
  end

  @doc """
  Flushes and removes the FireZone iptables chain.
  """
  def teardown do
    exec!(@teardown_chain_cmd)
  end

  @doc """
  Adds iptables rule.
  """
  def add_rule({4, s, d, :deny}) do
    exec!("iptables -A firezone -s #{s} -d #{d} -j DROP")
  end

  def add_rule({4, d, :deny}) do
    exec!("iptables -A firezone -d #{d} -j DROP")
  end

  def add_rule({4, s, d, :allow}) do
    exec!("iptables -A firezone -s #{s} -d #{d} -j ACCEPT")
  end

  def add_rule({6, s, d, :deny}) do
    exec!("iptables6 -A firezone -s #{s} -d #{d} -j DROP")
  end

  def add_rule({6, s, d, :allow}) do
    exec!("iptables6 -A firezone -s #{s} -d #{d} -j ACCEPT")
  end

  @doc """
  Deletes iptables rule.
  """
  def delete_rule({4, s, d, :deny}) do
    exec!("iptables -D firezone -s #{s} -d #{d} -j DROP")
  end

  def delete_rule({4, s, d, :allow}) do
    exec!("iptables -D firezone -s #{s} -d #{d} -j ACCEPT")
  end

  def delete_rule({6, s, d, :deny}) do
    exec!("iptables6 -D firezone -s #{s} -d #{d} -j DROP")
  end

  def delete_rule({6, s, d, :allow}) do
    exec!("iptables6 -D firezone -s #{s} -d #{d} -j ACCEPT")
  end
end
