FROM aowen14/litellm-oauth-fix:latest

# Create the config file with Phoenix observability
RUN cat > /app/config.yaml << 'EOF'
# LiteLLM Configuration with Wildcard Pass-through for Claude Code
# This allows Claude Code to select any model while maintaining observability

model_list:
  # Claude models with explicit provider prefix
  - model_name: "anthropic/*"
    litellm_params:
      model: "anthropic/*"
      api_key: os.environ/ANTHROPIC_API_KEY

  # Route unprefixed claude-* models to Anthropic provider
  - model_name: "claude-*"
    litellm_params:
      model: "anthropic/claude-*"
      api_key: os.environ/ANTHROPIC_API_KEY

litellm_settings:
  callbacks: ["arize_phoenix"]
  drop_params: false
  set_verbose: true
  pass_through_params: true
  disable_auth: true

router_settings:
  routing_strategy: "simple-shuffle"
  enable_pre_call_checks: false
  disable_cooldowns: true
  allowed_fails: 1000

environment_variables:
  PHOENIX_COLLECTOR_ENDPOINT: "http://phoenix:4317"
  PHOENIX_COLLECTOR_HTTP_ENDPOINT: "http://phoenix:6006/v1/traces"
EOF

# Default command - Railway will override port, but this is the base command structure
CMD ["--config", "/app/config.yaml", "--port", "4000", "--num_workers", "1"]
