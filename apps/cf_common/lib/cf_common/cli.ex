defmodule CfCommon.CLI do
  @moduledoc """
  Handles low-level CLI facilities.
  """

  def bash(cmd) do
    System.cmd("bash", ["-c", cmd])
  end

  def exec!(cmd) do
    case bash(cmd) do
      {result, 0} ->
        result

      {error, _} ->
        raise """
        Error executing command #{cmd} with error #{error}.
        CloudFire cannot recover from this error.
        """
    end
  end
end
