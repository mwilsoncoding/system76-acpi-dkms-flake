{
  description = ''
    System76 ACPI Driver (DKMS)
  '';

  inputs.nixpkgs.url = github:NixOS/nixpkgs/2d6cbbe4627f6fe4a179c681537b0a3e4f59b732;

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

        kernel = linuxPackages.kernel.dev;
        nativeBuildInputs = linuxPackages.kernel.moduleBuildDependencies;

        preBuild = ''
          sed -e "s@/lib/modules/\$(.*)@${linuxPackages.kernel.dev}/lib/modules/${linuxPackages.kernel.modDirVersion}@" -i Makefile
        '';
        
        installPhase = ''
          mkdir -p $out/lib/modules/${linuxPackages.kernel.modDirVersion}/misc
          cp system76_acpi.ko $out/lib/modules/${linuxPackages.kernel.modDirVersion}/misc

          # not sure if these are working
          mkdir -p $out/usr/share/initramfs-tools/hooks
          cp {$src,$out}/usr/share/initramfs-tools/hooks/system76-acpi-dkms

          mkdir -p $out/usr/share/initramfs-tools/modules.d
          cp {$src,$out}/usr/share/initramfs-tools/modules.d/system76-acpi-dkms.conf
        '';
      };

    nixosModules.system76-acpi-dkms =
      { pkgs, ... }:
      {
        config = {
          boot.extraModulePackages = pkgs.system76-acpi-dkms;
      
          # system76_acpi automatically loads on darp6, but system76_io does not.
          # Explicitly load both for consistency.
          boot.kernelModules = [ "system76_acpi" ];
        };
      };
  };
}
