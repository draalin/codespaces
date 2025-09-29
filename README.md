# Terraform Infrastructure & AI-Enabled Codespaces Template

<!-- Badges -->
![CI](https://github.com/draalin/codespaces/actions/workflows/terraform-ci.yml/badge.svg)
![Security Scans](https://img.shields.io/badge/scans-tfsec%20%7C%20checkov-blueviolet)
![Infracost](https://img.shields.io/badge/cost-Infracost-informational)
![Terraform Version](https://img.shields.io/badge/terraform-1.9.5-623CE4)
![License](https://img.shields.io/badge/license-CUSTOM-lightgrey)


Purpose: Rapidly provision and iterate on AWS infrastructure using Terraform inside GitHub Codespaces with a pre-baked toolchain (Terraform/Terragrunt, linting, docs, cost estimation) plus integrated AI coding assistants (Copilot, Claude Code) and voice/speech features. Designed to be copied into new repos and immediately productive.

## Features
- Dev Container / Codespaces ready
- Terraform, Terragrunt, TFLint, terraform-docs, Infracost, AWS CLI
- Pre-commit hooks (fmt, validate, tflint, docs, cost)
- Makefile for common workflows
- Automatic AWS profile selection via `.aws-profile` file
- Example module and env structure (`infrastructure/env/dev`, `infrastructure/modules/example`)
- AI assistants: GitHub Copilot & Chat, Claude Code
- Optional voice input (VS Code Speech)
- Cost awareness (Infracost)

## Getting Started
1. (Optional) Create a new repo from this template by copying its contents.
2. Open in GitHub Codespaces or locally with Dev Containers.
3. Ensure AWS SSO login or credentials are available on host (or mount secrets).
4. Set your backend remote state resources in `infrastructure/env/*/main.tf`.
5. Initialize:
```bash
make -C infrastructure/env/dev init
```
6. Plan:
```bash
make -C infrastructure/env/dev plan
```
7. Apply:
```bash
make -C infrastructure/env/dev apply AUTO=yes
```

## AWS Profile Auto-Selection
Place a file named `.aws-profile` at repo root (or any parent directory). Content should be the AWS CLI profile name. The wrapper script `scripts/tf-wrapper.sh` can be used if you prefer launching Terraform directly with profile discovery.

Example:
```bash
echo my-sso-admin > .aws-profile
```

## Pre-Commit Hooks
Install hooks:
```bash
make pre-commit-install
```
Run all hooks:
```bash
make pre-commit-run
```

## Generating Module Docs
`terraform-docs` runs via pre-commit. Manual run:
```bash
terraform-docs markdown table infrastructure/modules/example
```

## Cost Estimates
Set Infracost API key:
```bash
export INFRACOST_API_KEY=XXXX
make cost
```

## Terragrunt
If you prefer Terragrunt, adjust `Makefile` by exporting `TG=1` or directly call `terragrunt` in `infrastructure/env/*`.

## Directory Layout
```
infrastructure/
	env/
		dev/          Dev environment root module (apply from here)
		prod/         Prod environment root module
	modules/
		example/      Example reusable module
scripts/          Helper scripts
.devcontainer/    Dev container definition
```

## Security Notes
- Do not commit `terraform.tfvars` or secrets.
- Use SSO or ephemeral credentials; avoid static keys where possible.
- Adjust `.gitignore` if adding new sensitive patterns.

## Next Steps / Customization
- Add CI workflows (fmt/validate/plan) in `.github/workflows/`
- Integrate OPA / Conftest / Checkov for policy scanning
- Add test harness (e.g. Terratest) if coding custom modules

## License
Adapt as needed; add a LICENSE file appropriate for your org.

---

## Extension & API / Credential Configuration

Below are the primary tools and extensions and how to configure them (environment variables, tokens, or profiles). All secret values should live outside version control; use `.env` (copied from `.env.example`), GitHub Codespaces secrets, or organization secrets.

### AWS CLI / SSO
Preferred: AWS IAM Identity Center (SSO).

1. Configure profile locally in `~/.aws/config` (already mounted into the container) or directly inside container.
2. Run:
```bash
aws sso login --profile <your-sso-profile>
```
3. Set `.aws-profile` with that profile name to have wrapper & tooling pick it up automatically.

Environment variables (optional override):
```
AWS_PROFILE=your-profile
AWS_REGION=us-east-1
```

### Terraform
No API key required unless using Terraform Cloud:
```
TERRAFORM_CLOUD_TOKEN=...   # if using remote execution or private registry
```
State backend is defined per environment (`infrastructure/env/*/main.tf`). Update S3 bucket & DynamoDB table before first init.

### Terragrunt
Uses same AWS credentials as Terraform. Enable by invoking:
```bash
make -C infrastructure/env/dev TG=1 plan
```

### TFLint
No API key required. Configuration can be added via `.tflint.hcl` if needed.

### terraform-docs
No credentials required. Controlled by pre-commit hook arguments.

### Infracost
Sign up at https://www.infracost.io/ and obtain an API key.
```
INFRACOST_API_KEY=your_key
```
Run cost estimate:
```bash
make cost
```

### GitHub Copilot & Copilot Chat
Authentication is handled via your GitHub account. Ensure the extensions:
- `github.copilot`
- `github.copilot-chat`

Optional settings (add to `settings.json` if you want to tweak suggestions):
```jsonc
"github.copilot.inlineSuggest.enable": true,
"github.copilot.editor.enableAutoCompletions": true
```

### Claude Code (Anthropic)
The `anthropic.claude-code` extension uses your GitHub authentication if installed via marketplace. If you add scripts hitting Anthropic API directly, set:
```
ANTHROPIC_API_KEY=sk-ant-...
```
Store it via Codespaces secret or local environment export (never commit).

### OpenAI (Optional)
If you later add an OpenAI extension or CLI usage:
```
OPENAI_API_KEY=sk-...
```
Use repository / Codespaces secrets for ephemeral provisioning.

### VS Code Speech
No API key required; it uses built-in capabilities. Access via Command Palette: “Start Dictation” or enable voice commands if supported.

### Additional Suggested Integrations (Not Included Yet)
| Tool | Purpose | How to Add |
|------|---------|-----------|
| Checkov / tfsec | Security & compliance scanning | Add as pre-commit hook or CI job |
| OPA / Conftest | Policy as code | Add `policy/` dir + test step |
| Terratest | Module validation via Go tests | Create `test/` with Go harness |
| Snyk | Vulnerability scanning | Add CI pipeline job |

---

## Using `.env` for Local/Codespaces Variables
Duplicate `.env.example` to `.env` and populate keys:
```bash
cp .env.example .env
```
Load values (temporary shell session):
```bash
export $(grep -v '^#' .env | xargs)
```
Prefer GitHub Codespaces secrets for persistent secure variables.

## Typical Daily Flow
```bash
aws sso login --profile my-sso-admin
echo my-sso-admin > .aws-profile
make -C infrastructure/env/dev init
make -C infrastructure/env/dev plan
make -C infrastructure/env/dev apply AUTO=yes
make cost  # (optional cost visibility)
```

## Troubleshooting Quick Table
| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Terraform backend init fails | S3 bucket/table not created | Create state bucket & DynamoDB lock table first |
| No AWS identity | Forgot SSO login | Run `aws sso login --profile <profile>` |
| Infracost shows zero cost | No API key or unsupported resources | Set `INFRACOST_API_KEY` & rerun |
| Docs not updating | Pre-commit not installed | `make pre-commit-install` or run terraform-docs manually |
| AI suggestions missing | Extension disabled | Check extensions panel & sign in |

