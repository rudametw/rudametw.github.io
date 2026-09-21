---
title: "Configure PaperCut Kyocera printer with stapling on Linux"
categories: [linux, cups, printing, papercut]
place: Rennes, France
---

This guide details the configuration of a Kyocera TASKalfa queue (A4, long-edge duplex, top-left staple), covering both prompted and silent authentication methodologies.

<!--more-->

Enterprise printing environments often deploy CUPS spoolers fronted by accounting systems like PaperCut. Configuring client-side Linux machines to interface with these systems requires bypassing generic IPP drivers to expose proprietary hardware features, and handling authentication requirements explicitly.

## Prerequisites

Identify the target CUPS server, the queue name, and your domain credentials.

Query the server to get all of the queues and pick your target:
```bash
lpstat -h cups-rba.inria.fr -a
```

I want the color printer `printer-color-rba` because I can force b&w anytime, including at the printer when I select the jobs.

Test that you can get the printer settings you want:
```bash
curl http://cups-rba.inria.fr:631/printers/printer-color-rba.ppd
```

You should see all of the printer's options. We'll use that later.

So, I'm using this configuration:

*   **Server:** `cups-rba.inria.fr`
*   **Queue:** `printer-color-rba`
*   **Domain Login:** `<username>`
*   **Domain Password:** `<password>`


## Step 1: Extract the Raw Server PPD

Generic driver mappings (`-m everywhere`) strip proprietary PJL payloads required for hardware finishing mechanisms (e.g., stapling). Extract the exact PPD utilized by the remote spooler.

```bash
curl -s -o /tmp/kyocera_rba.ppd http://cups-rba.inria.fr:631/printers/printer-color-rba.ppd
```

## Step 2: Queue Configuration Options

This deployment forces the following parameters natively in the local spooler via the extracted Kyocera PPD:

*    `PageSize=A4`
*    `Duplex=DuplexNoTumble` (Long-edge binding)
*    `Scnt=All` (Staple entire job block)
*    `Stpl=Rear` (Hardware finisher position. Maps to Top-Left for transverse/LEF cassette orientation, if it staples wrong, try `Stpl=Front`).

## Step 3: Add the printer

### Option A: Prompted Authentication (Standard IPP)

This configuration binds a local queue (`printer-rba-prompt`) that relies on Polkit to dynamically request your domain credentials upon job submission. The transmission is unencrypted so don't add your password directly to the printer's URI.

```bash
sudo lpadmin -p "printer-rba-prompt" \
  -v 'ipp://<USERNAME>@cups-rba.inria.fr:631/printers/printer-color-rba' \
  -E \
  -P /tmp/kyocera_rba.ppd \
  -o PageSize=A4 \
  -o Duplex=DuplexNoTumble \
  -o Stpl=Rear \
  -o Scnt=All
```

`<USERNAME>` is optional but it allows all users on your computer to print to your account. If not, there's a risk that user `root` or whatever will send jobs that will be ignored.


### Option B: Silent Authentication (Encrypted IPPS)

This configuration binds a secondary queue (`printer-rba-password`) that embeds domain credentials directly into the URI, bypassing GUI prompts. It forces TLS encapsulation (`ipps://`) to prevent plaintext credential leakage on the network.

**1. Encode Credentials**

The IPP URI is parsed as a standard web link. Passwords containing special characters must be URL encoded.

```bash
read -s RAW_PASS; echo -n "$RAW_PASS" | python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read(), safe=''))"; unset RAW_PASS
```

**2. Instantiate Secure Queue**

Replace `<ENCODED_PASSWORD>` with the output from the previous step. This will disable local authentication requirements to prevent the CUPS daemon from blocking the job thread.

```bash
sudo lpadmin -p "printer-rba-silent" \
  -v 'ipps://<USERNAME>:<ENCODED_PASSWORD>@cups-rba.inria.fr:631/printers/printer-color-rba' \
  -E \
  -P /tmp/kyocera_rba.ppd \
  -o auth-info-required=none \
  -o PageSize=A4 \
  -o Duplex=DuplexNoTumble \
  -o Stpl=Rear \
  -o Scnt=All
```

**3. Verify TLS Certificate Chain**

If the server relies on an internal Certificate Authority rather than a public trust anchor, jobs sent to the `ipps://` queue will fail silently. You can validate the server's X.509 certificate with:


```bash
openssl s_client -showcerts -connect cups-rba.inria.fr:631 </dev/null 2>/dev/null | openssl x509 -inform pem -noout -text
```

If the issuer is an untrusted internal CA, inject it into the local trust store (e.g., /etc/pki/ca-trust/source/anchors/ on Fedora) and execute update-ca-trust to prevent connection rejection. Do not rely on ValidateCerts No in /etc/cups/client.conf, as it breaks the chain-of-trust.



## Step 4: Verification and Print Testing

Verify the queues are active via the local CUPS web interface at http://localhost:631/printers/. The list should reflect both printer-rba-silent and printer-rba-prompt.

Submit a standard test job via the command line to validate the configuration and routing:

```bash
# Test the prompted queue (requires Polkit GUI interaction)
lp -d printer-rba-prompt /usr/share/cups/data/default-testpage.pdf

# Test the silent queue (authenticates automatically)
lp -d printer-rba-silent /usr/share/cups/data/default-testpage.pdf
```

Check the PaperCut portal at https://print.inria.fr/app?service=page/UserReleaseJobs to confirm the jobs successfully authenticated and appear in PaperCut's release queue. Finally, badge and print the job at the physical machine to verify that the long-edge duplex and top-left stapling parameters executed correctly.

Remember, you can set other default options in http://localhost:631/printers/
