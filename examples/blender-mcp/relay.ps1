<#
  Blender MCP relay (user space, no administrator rights required)

  Purpose
    The "MCP for Blender" add-on binds its socket to 127.0.0.1:<BlenderPort>, so
    WSL2 in NAT networking mode cannot reach it. This relay accepts connections on
    <ListenPort> and forwards them, byte for byte, to 127.0.0.1:<BlenderPort>.

  Usage
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File relay.ps1 [-ListenPort 9877] [-BlenderPort 9876]
    Use relay.vbs to start it without a console window.

  Notes
    - Runs entirely in user space: no netsh portproxy, no Windows Firewall rule.
    - Binds 0.0.0.0 so the Windows side of the WSL vEthernet adapter is reachable.
      Anyone who can reach the port can run Python inside Blender, so keep the
      network profile at "Public" (inbound is blocked there by default).
#>
param(
  [int]$ListenPort = 9877,
  [int]$BlenderPort = 9876
)
$ErrorActionPreference = 'Stop'
$LogDir = Join-Path $env:LOCALAPPDATA 'blender-mcp'
$LogFile = Join-Path $LogDir 'relay.log'
$TargetHost = '127.0.0.1'

function Write-Log([string]$Message) {
  $line = "{0} {1}" -f (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK'), $Message
  Add-Content -Path $LogFile -Value $line
}

Add-Type -TypeDefinition @'
using System;
using System.Net;
using System.Net.Sockets;
using System.Threading;
public static class BlenderMcpRelay {
  public static void Start(int listenPort, string targetHost, int targetPort) {
    var listener = new TcpListener(IPAddress.Any, listenPort);
    listener.Start();
    var t = new Thread(() => {
      while (true) {
        TcpClient c;
        try { c = listener.AcceptTcpClient(); } catch { break; }
        ThreadPool.QueueUserWorkItem(delegate (object o) { Handle((TcpClient)o, targetHost, targetPort); }, c);
      }
    });
    t.IsBackground = true;
    t.Start();
  }
  static void Handle(TcpClient c, string th, int tp) {
    try {
      var u = new TcpClient();
      u.Connect(th, tp);
      var cs = c.GetStream();
      var us = u.GetStream();
      var a = cs.CopyToAsync(us);
      var b = us.CopyToAsync(cs);
      System.Threading.Tasks.Task.WaitAll(a, b);
      u.Close(); c.Close();
    } catch { try { c.Close(); } catch {} }
  }
}
'@

try {
  [BlenderMcpRelay]::Start($ListenPort, $TargetHost, $BlenderPort)
} catch {
  Write-Log "failed to listen on 0.0.0.0:${ListenPort}: $($_.Exception.Message)"
  exit 1
}
Write-Log "relay listening 0.0.0.0:${ListenPort} -> ${TargetHost}:${BlenderPort} (pid $PID)"
while ($true) { Start-Sleep -Seconds 3600 }
