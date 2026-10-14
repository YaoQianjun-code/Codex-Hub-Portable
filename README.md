# Codex Hub Portable

A lightweight portable environment initializer for Codex Hub with isolated OpenAI Codex and DeepSeek interfaces.

## Overview

Codex Hub Portable is designed to simplify the deployment and initialization of Codex Hub environments.

This project does not provide built-in AI accounts, API keys, or user credentials.

Users only need to:

- Install the official OpenAI Codex CLI
- Login with their own OpenAI account
- Configure DeepSeek API Key if required

The initialization scripts handle environment preparation and interface configuration.

## Features

- One-click environment initialization
- Independent OpenAI Codex interface
- Independent DeepSeek API interface
- Portable deployment
- User-side account and API configuration
- No dependency on virtual machine environments

## Installation

### Requirements

Before installation, make sure you have:

- Windows operating system
- Official OpenAI Codex CLI installed
- OpenAI account authentication completed

Optional:

- DeepSeek API Key

### Setup

1. Download the latest release:

https://github.com/YaoQianjun-code/Codex-Hub-Portable/releases

2. Extract the package.

3. Run:

```cmd
Start-Setup.cmd
```

4. Follow the instructions to complete initialization.

The script will automatically prepare the required environment.

## Interfaces

Codex Hub Portable provides independent interface configurations.

### OpenAI Codex

Uses the official OpenAI Codex CLI environment.

Users authenticate through their own OpenAI account.

### DeepSeek

Supports independent DeepSeek API configuration.

Users provide their own DeepSeek API Key.

## Project Structure

```text
Codex Hub Portable
│
├── Codex Hub
│   └── codex-hub.exe
│
├── tools
│   └── Setup scripts
│
├── Start-Setup.cmd
│
├── VERSION.txt
│
└── README.md
```

## Notes

This project does not include:

- OpenAI accounts
- API keys
- User credentials

All AI services must be configured by users themselves.

The project only provides environment initialization and interface preparation.

## Version

Current version:

```text
v4.2.0
```

## License

For personal and educational use.