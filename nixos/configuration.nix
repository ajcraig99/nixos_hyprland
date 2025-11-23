# This is the main NixOS configuration file.
{ config, lib, pkgs, quickshell, spicetify-nix, ... }:

{
  # Imports:
  imports =
    [
      # Include the results of the hardware scan, essential for system specific drivers and modules.
      ./hardware-configuration.nix
    ];

  # Enable experimental features for Nix command and flakes.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Allow installation of unfree packages (e.g., proprietary drivers, some applications).
  nixpkgs.config.allowUnfree = true;
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  # Enable necessary kernel modules for cifs
  boot.supportedFilesystems = [ "cifs" ];
  # Define your hostname for network identification.
  networking.hostName = "nixos";
  # Enable NetworkManager for easy network configuration.
  networking.networkmanager.enable = true;
  boot.kernelModules = [ "iwlwifi" "i2c-dev"];
  # Set your system's time zone.
  time.timeZone = "Pacific/Auckland";
  # Configure basic audio support with PipeWire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  hardware.pulseaudio.enable = false; 
  
    hardware.sane = {
      enable = true;
      extraBackends = [ pkgs.sane-backends ];
    };

    # USB device access
    services.udev.packages = [ pkgs.sane-backends ];



    services.udev.extraRules = ''
      # Canon CanoScan LiDE 400
      ATTR{idVendor}=="04a9", ATTR{idProduct}=="1912", MODE="0664", GROUP="scanner", ENV{libsane_matched}="yes"
    '';
  
  # 2. Hardware Specific Configuration
  # NVIDIA specific kernel parameters (Original settings).
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/var/tmp" 
  ];
  # NVIDIA display drivers and settings (Original settings).
  services.xserver.videoDrivers = [ "nvidia" ]; # Re-added as it was in your original config.
  hardware.nvidia = {
    modesetting.enable = true;      # Enable DRM modesetting.
    powerManagement.enable = true; # Reverted to original: Power management disabled.
    powerManagement.finegrained = false;
    open = false;                   # Use proprietary driver for RTX 3060.
    nvidiaSettings = true;          # Allow access to nvidia-settings utility.
    package = config.boot.kernelPackages.nvidiaPackages.stable; # Reverted to original: Use stable driver.
  };
  # General graphics configuration (updated for NixOS 25.05).
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Enable 32-bit graphics support for compatibility.
  };
  # Enable i2c permissions
  hardware.i2c.enable = true;
  # Bluetooth configuration.
  hardware.bluetooth.enable = true;     # Enable Bluetooth functionality.
  hardware.bluetooth.powerOnBoot = true; # Turn on Bluetooth when the system boots.
  services.blueman.enable = true;       # Enable Blueman, a graphical Bluetooth manager.
  # Enable Qemu
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd.qemu.runAsRoot = false;  # Optional: run QEMU as user instead of root
  systemd.services.libvirtd.wantedBy = [ "multi-user.target" ];
  virtualisation.libvirtd.qemu.swtpm.enable = true; 
  
  services.logind = {
    extraConfig = ''
      IdleAction=hibernate
      IdleActionSec=2min
    '';
    };

  # 3. Programs & Applications
  environment.systemPackages = with pkgs; [
    # Basic Utilities
    git                   # Version control system.
    micro                 # Terminal-based text editor.
    wget                  # Network downloader.
    curl                  # Tool for transferring data with URLs.
    tree                  # List contents of directories in a tree-like format.
    fastfetch             # Neofetch-like system info tool.
    vesktop               # Discord client
    peazip                # Archive manager
    networkmanagerapplet  # Network manager
    linux-firmware        # Firmware for wifi card
    bc                    # Basic calculator
    cifs-utils            # For SMB mounting
    nvtopPackages.nvidia  # GPU monitor in terminal
    btop                  # System monitor
    dysk
    veracrypt
    sane-backends
    sane-frontends
    xsane
    simple-scan
    cnijfilter2
    usbutils
    # Web Browser
    firefox
    # Multimedia
    vlc                   # Versatile media player.
    ffmpegthumbnailer     # Thumbnailer for video files.
    loupe                 # Simple image viewer.
    gthumb                # Image viewer and organizer.
    ffmpeg                # Video converter
    mpv                   # Media control dependancy
    pavucontrol           
    easyeffects
    jq
    socat
    wireplumber
    playerctl
    yt-dlp                # Youtube downloader
    musikcube             # Terminal music player
    cava                  # Terminal visualiser
    steam                 # Its just steam
    # Terminal Emulators
    alacritty             # GPU-accelerated terminal emulator.
    kitty
    foot
    # Wayland/Hyprland Specific Tools
    waybar                # Highly customizable Wayland bar.
    wofi                  # Launcher for Wayland.
    hyprpaper             # Wallpaper changer
    hyprlock
    hypridle
    ddcutil
    wl-clipboard          # Wayland clipboard utilities.
    grim                  # Grab images from a Wayland compositor.
    slurp                 # Select a region on screen in Wayland.
    grimblast             # Wrapper for grim and slurp for screenshots.
    wf-recorder           # Screen recording utility for Wayland.
    libnotify             # Library for sending desktop notifications.
    rofi-wayland          # Rofi port for Wayland.
    swaynotificationcenter # Notification daemon for Sway/Hyprland.
    swww                  # Wallpaper daemon for Wayland.
    wlogout               # Logout manager
    # File Management
    nemo                  # Feature-rich file manager (Cinnamon's default).
    nemo-fileroller       # Archive integration for Nemo.
    gvfs                  # GNOME Virtual File System (needed for various file operations).
    xfce.tumbler          # Thumbnail service (specifically XFCE's, often used with Nemo).
    webp-pixbuf-loader    # WebP image format support for GTK applications.
    p7zip
    # Zsh and its plugins/tools
    zsh                   # Zsh shell.
    zsh-autosuggestions   # Suggests commands as you type.
    zsh-syntax-highlighting # Highlights commands as you type.
    zsh-powerlevel10k     # Highly customizable Zsh theme.
    fzf                   # Fuzzy finder for command line.
    bat                   # Cat clone with syntax highlighting and Git integration.
    eza                   # Modern replacement for ls.
    # General tools and applications
    obsidian              # Note taking
    gnome-calendar        # Calander app  
    inkscape-with-extensions 
    gimp
    pdf4qt
    onlyoffice-desktopeditors
    
    # QuickShell for Nix package management, ensure it's built for your system.
    quickshell.packages.${pkgs.system}.default

    # Theming related packages
    catppuccin-cursors.mochaDark # Catppuccin themed cursors.
    catppuccin-gtk        # Catppuccin GTK theme.
    dracula-theme         # Dracula GTK theme
    dracula-qt5-theme
    capitaine-cursors     # Capitaine cursor pack
    adwaita-icon-theme    # Default GNOME icon theme (good fallback).
    gtk3                  # GTK 3 library (required by many GTK apps).

    # Custom mp3 audiobook converter tool
    (pkgs.writeShellScriptBin "mp3tom4b" ''
      exec ${pkgs.bash}/bin/bash "/mnt/NAS/Data/70-79 Tools&Software/76 - Linux/76.01 - Bash/merge_mp3_m4b.sh" "$@"
    '')

    # SDDM Catppuccin theme configuration, built as a system package.
    (catppuccin-sddm.override {
      flavor = "mocha";  # Catppuccin flavor for SDDM.
      font = "JetBrains Mono"; # Use JetBrains Mono as the font for SDDM.
      fontSize = "10";
      background = "/home/arron/Pictures/wallpapers/liquid-marbling-paint.jpg"; # Custom SDDM background.
      loginBackground = true; # Apply background to login screen.
    })
  ];

  # Font packages for various applications.
  fonts.packages = with pkgs; [
    jetbrains-mono              # JetBrains Mono regular font.
    nerd-fonts.jetbrains-mono   # Nerd Fonts variant of JetBrains Mono (for glyphs).
    nerd-fonts.fira-code        # Fira Code Nerd Font.
    font-awesome                # Icon font, often used in status bars.
  ];

  #############################################################################
  # 4. Desktop Environment & Services
  #    Configuration for Hyprland, Xorg, Display Manager, and theming.
  #############################################################################

  # Hyprland (Wayland compositor) configuration.
  programs.hyprland = {
    enable = true;          # Enable Hyprland.
    xwayland.enable = true; # Enable XWayland for X11 application compatibility on Wayland.
  };

  # X11 server configuration.
  services.xserver = {
    enable = true; # Enable X11 server for applications that require it.
  };

  # Disable GDM if it was previously enabled, using the new option name.
  # This option was only renamed, not functionally changed in a way that should cause issues.
  services.displayManager.gdm.enable = false;

  # SDDM (Simple Desktop Display Manager) with Catppuccin theme.
  services.displayManager.sddm = {
    enable = true;      # Enable SDDM.
    wayland.enable = true; # Enable Wayland support for SDDM.
    theme = "catppuccin-mocha"; # Set the SDDM theme.
    package = pkgs.kdePackages.sddm; # Use the KDE package for SDDM.
  };

  # XDG portal for better Wayland integration (screen sharing, file dialogs).
  xdg.portal = {
    enable = true;          # Enable XDG portal.
    wlr.enable = true;      # Enable wlroots-specific portal for Hyprland.
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; # Add GTK portal for GTK applications.
  };

  # Enable dconf for GTK applications to store settings.
  programs.dconf.enable = true;

  # GTK Theming configuration via environment.etc.
  # This sets preferred themes for GTK2/3/4 applications.
  environment.etc = {
    # GTK 3 settings.ini
    "gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme=true
      gtk-theme-name=catppuccin-frappe-blue-standard
      gtk-icon-theme-name=Adwaita
      gtk-cursor-theme-name=catppuccin-mocha-dark-cursors
      gtk-cursor-theme-size=24
    '';

    # GTK 4 settings.ini
    "gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme=true
      gtk-theme-name=catppuccin-frappe-blue-standard
      gtk-icon-theme-name=Adwaita
      gtk-cursor-theme-name=catppuccin-mocha-dark-cursors
      gtk-cursor-theme-size=24
    '';
  };

  # Session variables for NVIDIA + Wayland to ensure proper application rendering.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";             # Forces Electron apps to use Wayland.
    GBM_BACKEND = "nvidia-drm";       # Specifies the Generic Buffer Management backend.
    __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # Ensures NVIDIA's GLX library is used.
    LIBVA_DRIVER_NAME = "nvidia";     # Sets VA-API driver for NVIDIA.
    WLR_NO_HARDWARE_CURSORS = "1";    # Fixes potential cursor issues on some Wayland setups.
    GTK_THEME = "catppuccin-frappe-blue-standard"; # Explicitly set GTK theme for session.
  };

  # Enable thumbnail service for file managers (e.g., Nemo).
  services.tumbler.enable = true;
  # Enable GVFS for better file system support (e.g., accessing network shares).
  services.gvfs.enable = true;

  #############################################################################
  # 5. User Configuration
  #    Defining user accounts and their specific settings.
  #    Please remember to change the initial password after the first boot!
  #############################################################################

  # Define your user account.
  users.users.arron = {
    isNormalUser = true; # Designate 'arron' as a normal user.
    extraGroups = [ "wheel" "networkmanager" "video" "i2c" "libvirtd" "scanner" "lp" ]; # Add user to 'wheel' (for sudo) and 'networkmanager' groups.
    initialPassword = "password"; # Set an initial password (CHANGE THIS AFTER INITIAL BOOT!).
    packages = with pkgs; [
      # User-specific packages can go here if you don't want them system-wide.
    ];
  };

  # Allow users in the 'wheel' group to use sudo without a password (for convenience).
  security.sudo.wheelNeedsPassword = false;

  # Set the default shell for all users to Zsh.
  users.defaultUserShell = pkgs.zsh;

  # Zsh shell specific configuration.
  programs.zsh = {
    enable = true;          # Enable Zsh.
    enableCompletion = true; # Enable tab completion.
    autosuggestions.enable = true; # Enable command autosuggestions.
    syntaxHighlighting.enable = true; # Enable syntax highlighting.

    # Custom shell aliases for convenience.
    shellAliases = {
      ll = "ls -l";
      la = "ls -la";
      ls = "eza";                     # Replace ls with eza for enhanced output.
      cat = "bat";                    # Replace cat with bat for syntax highlighting.
      rebuild = "cd /etc/nixos && sudo nixos-rebuild switch --flake .#nixos"; # Rebuild and switch to new configuration.
      nixconfig = "sudo micro /etc/nixos/configuration.nix"; # Easily edit this file.
      hyprlandconfig = "micro ~/.config/hypr/hyprland.conf"; # Easily edit Hyprland config.

      # Git aliases for common Git commands.
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline";

      # Directory navigation shortcuts.
    ".." = "cd ..";
    "..." = "cd ../..";

      # System shortcuts.
      ff = "fastfetch";             # Run fastfetch.
      clean = "nix-collect-garbage -d"; # Clean up old Nix generations and store paths.
    };

    # Additional Zsh configuration for Powerlevel10k and fzf.
    # The string escaping for Zsh variables is kept as it was a syntax fix.
    interactiveShellInit = ''
      # Enable Powerlevel10k instant prompt for faster startup.
      if [[ -r "$${XDG_CACHE_HOME:-$$HOME/.cache}/p10k-instant-prompt-$${(%):-%n}.zsh" ]]; then
        source "$${XDG_CACHE_HOME:-$$HOME/.cache}/p10k-instant-prompt-$${(%):-%n}.zsh"
      fi

      # Load Powerlevel10k theme
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

      # fzf key bindings
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh
    '';
  };



  # Spicetify configuration for Spotify theming.
  programs.spicetify =
  let
    # Get the spicetify-nix package set for the current system.
    spicePkgs = spicetify-nix.legacyPackages.${pkgs.system};
  in
  {
    enable = true; # Enable Spicetify.
    theme = spicePkgs.themes.text; # Set the desired Spicetify theme (e.g., 'text' is a placeholder, change to your preferred Catppuccin theme if available).
  };

  # Enable a systemd user service to automatically log out the session before suspend.
      # This will return you to the SDDM login screen upon resuming from sleep.
      systemd.user.services.logout-on-suspend = {
        description = "Log out user session before suspend";
        serviceConfig = {
          ExecStart = "${pkgs.systemd}/bin/loginctl terminate-session $XDG_SESSION_ID";
          Type = "oneshot";
        };
        wantedBy = [ "sleep.target" ];
        before = [ "sleep.target" ];
      };

  #############################################################################
  # 6. System State Version
  #    Crucial for maintaining compatibility with application data. DO NOT CHANGE lightly.
  #############################################################################

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Your current NixOS stable version.

  #############################################################################
  # 7. Unused or Commented-Out Code
  #    Sections of the configuration that are currently not active.
  #    Move active code from here to its appropriate section above.
  #    Please review these and remove any you are sure you won't use.
  #############################################################################

  # Networking Proxy (Uncomment and configure if you need a proxy)
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Internationalization Properties (Uncomment and configure if needed)
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # X11 Keymap Configuration (Uncomment and configure if needed for X11 specific keymaps)
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # CUPS (Common Unix Printing System) - Enable to print documents.
  # services.printing.enable = true;

  # GnuPG agent configuration (uncomment if you use GPG or SSH via GPG agent)
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # OpenSSH daemon (Uncomment to enable SSH server)
  # services.openssh.enable = true;

  # Firewall configuration (Uncomment and configure specific ports or disable entirely)
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file to the resulting system.
  # This is useful in case you accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

}
