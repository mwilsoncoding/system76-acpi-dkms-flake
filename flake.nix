{
  description = ''
    System76 ACPI Driver (DKMS)
  '';

  inputs.nixpkgs.url = github:NixOS/nixpkgs/2247d824fe07f16325596acc7faa286502faffd1;

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
          rev = "1.0.2";
          sha256 = "1i7zjn5cdv9h00fgjg46b8yrz4d3dqvfr25g3f13967ycy58m48h";
        };

        hardeningDisable = [ "pic" ];
        dontStrip = true;
        dontPatchELF = true;

        kernel = linuxPackages_5_8.kernel.dev;
        nativeBuildInputs = linuxPackages_5_8.kernel.moduleBuildDependencies;

        preBuild = ''
          sed -e "s@/lib/modules/\$(.*)@${linuxPackages_5_8.kernel.dev}/lib/modules/${linuxPackages_5_8.kernel.modDirVersion}@" -i Makefile
        '';
        
        installPhase = ''
          mkdir -p $out/lib/modules/${linuxPackages_5_8.kernel.modDirVersion}/misc
          cp system76_acpi.ko $out/lib/modules/${linuxPackages_5_8.kernel.modDirVersion}/misc

          # not sure if these are working
          mkdir -p $out/usr/share/initramfs-tools/hooks
          cp {$src,$out}/usr/share/initramfs-tools/hooks/system76-acpi-dkms

          mkdir -p $out/usr/share/initramfs-tools/modules.d
          cp {$src,$out}/usr/share/initramfs-tools/modules.d/system76-acpi-dkms.conf
        '';
      };
  };
}
