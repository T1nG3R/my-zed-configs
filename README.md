# My Zed Configurations

This repository contains my personal configuration files for the [Zed](https://zed.dev/) editor. 

While it includes standard UI preferences, keymaps, and build tasks, the core highlight of this repository is a **custom, zero-friction local AI autocomplete integration** for Windows. It utilizes `llama.cpp` and `Qwen2.5-Coder` with automated process lifecycle and VRAM management.

## The Local AI Integration

Running local LLMs for code completion (FIM - Fill-in-the-Middle) is great for privacy and offline work, but leaving the model loaded in VRAM when the editor is closed is highly inefficient. 

To solve this, I built a background process manager using PowerShell and VBScript. It seamlessly launches the `llama-server` backend when you want it and automatically kills the process to free up VRAM the moment Zed is closed.

### How it works
1. **The Entry Point (`Invisible_qwen.vbs`)**: A minimal VBScript wrapper that executes the PowerShell launcher. This prevents the native Windows console host from flashing a blank terminal window on startup and resolves "Run as administrator" problem.
2. **The Process Manager (`Zed_AI_Launcher.ps1`)**: 
   - Checks if `llama-server.exe` is already running to prevent duplicate instances and VRAM overflow.
   - Spawns the `llama.cpp` server as a hidden background daemon.
   - Launches `zed.exe` (if not already open) and attaches a monitoring loop to the process.
   - Gracefully waits. Once all `zed` processes are terminated by the user, it forcefully stops `llama-server`, immediately freeing up GPU resources.
3. **Zed Editor (`settings.json`)**: Configured to point the `edit_predictions` provider to the local `localhost:8080` OpenAI-compatible endpoint exposed by `llama.cpp`.


## 📂 Repository Structure

* `settings.json`: Core editor configuration (theme, fonts, telemetry disabled, local LLM endpoints, and Gemini agent setup).
* `keymap.json`: Custom keybindings (e.g., `F7` to run Python scripts or open HTML files directly from the editor).
* `tasks.json`: Custom tasks mapped to the keybindings, including a task to manually trigger the AI process manager from within Zed.
* `.gitattributes`: Ensures GitHub correctly parses `.json` files with comments as `JSONC`.
* `qwen llama.cpp autocomplete/`: Contains the Windows-specific scripts (`.ps1`, `.vbs`, and shortcut `.lnk`) required for the local AI lifecycle management.

## ⚠️ Disclaimer for Anyone Cloning

This is a **personal configuration repository**. It is highly tailored to my specific Windows environment and hardware constraints (specifically optimizing for a 6GB VRAM limit on an NVIDIA GTX 1660 Ti). 

If you plan to use this setup, you **must** update the hardcoded paths in the scripts and tasks:
1. Open `Zed_AI_Launcher.ps1` and `tasks.json`.
2. Update the paths to your `zed.exe` installation (typically `%LocalAppData%\Programs\Zed\zed.exe`).
3. Update the paths to your `llama-server.exe` and your specific `.gguf` model file.
4. Ensure your model fits within your GPU's VRAM alongside the `ctx` size defined in the script (`-c 4096`).

## 🛠️ Requirements for the AI Setup

If adapting this for your own machine, you will need:
* **OS**: Windows 10/11.
* **Backend**: [llama.cpp](https://github.com/ggerganov/llama.cpp) compiled with CUDA support.
* **Model**: A fast coding model in GGUF format (e.g., `qwen2.5-coder-1.5b-q8_0.gguf`).
