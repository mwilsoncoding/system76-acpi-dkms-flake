# system76-acpi-dkms-flake
Flake that fetches src

## How to use
Write your own System76 [Model] flake that lists this repository as an input and defines a module for it in the following way:
```nix
{
  description = "Bare configuration for a System76 [Model]";

  # This nixpkgs must be the same one used to build the system76 packages
  inputs.nixpkgs.url = github:NixOS/nixpkgs/b3251e04ee470c20f81e75d5a6080ba92dc7ed3f;
  inputs.system76AcpiDkms.url = github:mwilsoncoding/system76-acpi-dkms-flake/latest-sha-0000000;
  ...

  outputs = { self, nixpkgs, system76AcpiDkms, ... }: {

    nixosModules = {
      compatibleKernel =
        {
          config = {
            boot.kernelPackages = (import nixpkgs {system = "x86_64-linux";}).linuxPackages_latest;
          };
        };
      system76AcpiDkms =
        {
          config = {
            boot.extraModulePackages = [ system76AcpiDkms.defaultPackage.x86_64-linux ];
        
            # system76_acpi automatically loads on darp6, but system76_io does not.
            # Explicitly load both for consistency.
            boot.kernelModules = [ "system76_acpi" ];
          };
        };
      ...
    };
  };
}
```

### What's this `compatibleKernel` nonsense?
When writing the System76 [Model] flake that defines the necessary modules, specify one, named `compatibleKernel`, that defines which most-up-to-date kernel works with the hardware you'll be deploying to.

This frees your outermost nix flake to use whatever version of nixpkgs they like, even if it does not provide the kernel specified here.

Finding which kernels work with the System76 drivers is a matter of specifying vNext, rebooting, and seeing if it works. If it doesn't, revert back to the kernel previously specified.
