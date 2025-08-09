{
  services = {
    ollama = {
      enable = true;
      port = 11434;
      openFirewall = true;
      host = "0.0.0.0";
      acceleration = "rocm";
      environmentVariables = {
        HCC_AMDGPU_TARGET = "gfx1031";
      };
      rocmOverrideGfx = "10.3.0";
      loadModels = [
        "qwen3:14b"
        "gemma3:12b"
        "gpt-oss:20b"
      ];

    };

    open-webui = {
      enable = true;
      port = 8080;
      openFirewall = true;
      host = "0.0.0.0";

    };

    immich = {
      enable = true;
      port = 2283;
      openFirewall = true;
      host = "0.0.0.0";
    };

  };

}
