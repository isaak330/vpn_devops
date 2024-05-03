import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:openvpn_flutter/openvpn_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late OpenVPN engine;
  VpnStatus? status;
  VPNStage? stage;
  bool _granted = false;
  @override
  void initState() {
    engine = OpenVPN(
      onVpnStatusChanged: (data) {
        setState(() {
          status = data;
        });
      },
      onVpnStageChanged: (data, raw) {
        setState(() {
          stage = data;
        });
      },
    );

    engine.initialize(
      localizedDescription: "VPN by Zalipuha",
      lastStage: (stage) {
        setState(() {
          this.stage = stage;
        });
      },
      lastStatus: (status) {
        setState(() {
          this.status = status;
        });
      },
    );
    super.initState();
  }

  Future<void> initPlatformState() async {
    engine.connect(config, "RU");
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('DevOps VPN'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              stage == VPNStage.disconnected
                  ? const Icon(
                      Icons.wifi_off,
                      color: Colors.red,
                      size: 60,
                    )
                  : stage == VPNStage.connected
                      ? const Icon(
                          Icons.wifi,
                          color: Colors.green,
                          size: 60,
                        )
                      : const CircularProgressIndicator(
                          color: Colors.yellow,
                        ),
              //  Text(stage?.toString() ?? VPNStage.disconnected.toString()),
              const SizedBox(
                height: 32,
              ),
              Text('Время сессии: ${status?.toJson()['duration'].toString()}' ??
                  ""),
              Text(
                  'Пакетов получено: ${status?.toJson()['packets_in'].toString()}' ??
                      ""),
              Text(
                  'Пакетов отправлено: ${status?.toJson()['packets_out'].toString()}' ??
                      ""),
              const SizedBox(
                height: 32,
              ),
              TextButton(
                child: const Text("Подключиться"),
                onPressed: () {
                  initPlatformState();
                },
              ),
              TextButton(
                child: const Text("Отключиться"),
                onPressed: () {
                  engine.disconnect();
                },
              ),
              if (Platform.isAndroid)
                TextButton(
                  child: Text(_granted ? "" : "Запросить доступ"),
                  onPressed: () {
                    engine.requestPermissionAndroid().then((value) {
                      _granted = value;
                      setState(() {});
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String config = """
client
proto tcp-client
remote 141.105.64.242 993
dev tun
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
verify-x509-name server_Bsmfatp234p4qH7k name
auth SHA256
auth-nocache
cipher AES-128-GCM
tls-client
tls-version-min 1.2
tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
ignore-unknown-option block-outside-dns
setenv opt block-outside-dns # Prevent Windows 10 DNS leak
verb 3
<ca>
-----BEGIN CERTIFICATE-----
MIIB1zCCAX2gAwIBAgIUVUvv1xoa7cYEbwckc0ij0rG0zn0wCgYIKoZIzj0EAwIw
HjEcMBoGA1UEAwwTY25fRUFoRnkxVGNNR2dHaWRUTjAeFw0yNDA1MDIwNjA2NDNa
Fw0zNDA0MzAwNjA2NDNaMB4xHDAaBgNVBAMME2NuX0VBaEZ5MVRjTUdnR2lkVE4w
WTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAATnEO9glTOPuy6Rk6PEQ/x7zAz7dd1i
bQyyuPVPWjmCh+J/0AgqMp6fIg4w1PK3+9u5uG84lkxwXpcoNpcS0Emmo4GYMIGV
MAwGA1UdEwQFMAMBAf8wHQYDVR0OBBYEFFpRZVM+DcbA90uizaDeaTadSszdMFkG
A1UdIwRSMFCAFFpRZVM+DcbA90uizaDeaTadSszdoSKkIDAeMRwwGgYDVQQDDBNj
bl9FQWhGeTFUY01HZ0dpZFROghRVS+/XGhrtxgRvByRzSKPSsbTOfTALBgNVHQ8E
BAMCAQYwCgYIKoZIzj0EAwIDSAAwRQIgVntPVK+Lm0s3q5HSJbrbS5YkPt/7kqRm
ETbYFwDpFYcCIQDR0qKvELMVjzYliQxK5Wlf4a9/p49DT5BYulLN9KEN1g==
-----END CERTIFICATE-----
</ca>
<cert>
-----BEGIN CERTIFICATE-----
MIIB2TCCAX+gAwIBAgIRAMI8nzWr3tykfJYOTB+IhTYwCgYIKoZIzj0EAwIwHjEc
MBoGA1UEAwwTY25fRUFoRnkxVGNNR2dHaWRUTjAeFw0yNDA1MDIwNjA3MTRaFw0y
NjA4MDUwNjA3MTRaMBExDzANBgNVBAMMBmRldm9wczBZMBMGByqGSM49AgEGCCqG
SM49AwEHA0IABKMo/u9KL2ln5CuIycfidDt38ZmYt6/x1QwkNNplMZisRWERSYAb
VLNQVW5ETs8RbLEcM9V7YKlVVZfS3kR+RgGjgaowgacwCQYDVR0TBAIwADAdBgNV
HQ4EFgQUfTzD4QWmSeWFWOZtp+fLP6+dgrgwWQYDVR0jBFIwUIAUWlFlUz4NxsD3
S6LNoN5pNp1KzN2hIqQgMB4xHDAaBgNVBAMME2NuX0VBaEZ5MVRjTUdnR2lkVE6C
FFVL79caGu3GBG8HJHNIo9KxtM59MBMGA1UdJQQMMAoGCCsGAQUFBwMCMAsGA1Ud
DwQEAwIHgDAKBggqhkjOPQQDAgNIADBFAiBwOjK3bf5PkFl9F4GbkpB/ANdmeuVj
y6YpXmfu+QxfVwIhAKRDMrgTaSkfW/KHRGjgQKDyhWfTfi3Px+5+YLcKOOps
-----END CERTIFICATE-----
</cert>
<key>
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQg7HJguZD/iG0Gfj4k
7J/FmJ9DP50Al4Oe6WFTwgGncIGhRANCAASjKP7vSi9pZ+QriMnH4nQ7d/GZmLev
8dUMJDTaZTGYrEVhEUmAG1SzUFVuRE7PEWyxHDPVe2CpVVWX0t5EfkYB
-----END PRIVATE KEY-----
</key>
<tls-crypt>
#
# 2048 bit OpenVPN static key
#
-----BEGIN OpenVPN Static key V1-----
ec47477e2483b77d9d56e7abf4ec5d26
5b81a5d3b55c7874a44a3e79dbc8a657
617de9ded2b92f49d6cd97f3632d8b2d
f661b1317c04ce28cc0ae31ae4ba5bc4
40e5da8386dfda766bdfdcbac6c10dfe
495d2c578bfe691e2ba8dfc75c8ac8d0
783a2cf58d243eaba30ac4093bbb6f4f
25b292ab143a4e7e07a150fbad094b59
b07302366241f720f50203b2fdf18ac8
f67eb9605831aea61896cab453e440eb
1728f1b35e9f137f985b84cf74cc9b1f
b99931a3a039a7c02595fd89dc5feb27
373caa508bc110b73786f09789ab4dd8
33099222bd0868d41105948a4ffa1383
3d6b82004150230a4a371a682fa4be0f
c78dd4cfadd6e76b37926268c73f7d49
-----END OpenVPN Static key V1-----
</tls-crypt>
""";
