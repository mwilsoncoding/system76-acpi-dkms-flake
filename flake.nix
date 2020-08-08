{
  description = ''
    System76 ACPI Driver (DKMS)
  '';

  inputs.nixpkgs.url = github:NixOS/nixpkgs/b3251e04ee470c20f81e75d5a6080ba92dc7ed3f;

  outputs = { self, nixpkgs }: {

    defaultPackage.x86_64-linux = 
      with import nixpkgs {
        system = "x86_64-linux";
      };
      stdenv.mkDerivation {
        name = "system76-acpi-dkms";
        #version = 1.0.1;
        src = fetchFromGitHub {
          owner = "pop-os";
          repo = "system76-acpi-dkms";
          rev = "1.0.1";
          sha256 = "0jmm9h607f7k20yassm6af9mh5l00yih5248wwv4i05bd68yw3p5";
        };

        hardeningDisable = [ "pic" ];
        dontStrip = true;
        dontPatchELF = true;

        kernel = linuxPackages_latest.kernel.dev;
        nativeBuildInputs = linuxPackages_latest.kernel.moduleBuildDependencies;

        preBuild = ''
          sed -e "s@/lib/modules/\$(.*)@${linuxPackages_latest.kernel.dev}/lib/modules/${linuxPackages_latest.kernel.modDirVersion}@" -i Makefile
        '';
        
        installPhase = ''
          mkdir -p $out/lib/modules/${linuxPackages_latest.kernel.modDirVersion}/misc
          cp system76_acpi.ko $out/lib/modules/${linuxPackages_latest.kernel.modDirVersion}/misc

          # not sure if these are working
          mkdir -p $out/usr/share/initramfs-tools/hooks
          cp {$src,$out}/usr/share/initramfs-tools/hooks/system76-acpi-dkms

          mkdir -p $out/usr/share/initramfs-tools/modules.d
          cp {$src,$out}/usr/share/initramfs-tools/modules.d/system76-acpi-dkms.conf
        '';
      };
  };
}
