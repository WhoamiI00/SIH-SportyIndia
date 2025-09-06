{{flutter_js}}
{{flutter_build_config}}

const loading = document.getElementById('loading');
const loadingText = document.getElementById('loading-text');

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    loadingText.textContent = "Initializing engine...";
    const appRunner = await engineInitializer.initializeEngine();
    
    loadingText.textContent = "Starting app...";
    await appRunner.runApp();
    
    // Hide loading screen
    loading.style.display = 'none';
  }
});
