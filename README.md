# Networking Module

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![CI Status](https://github.com/madabank/madabank-ios/actions/workflows/ci.yml/badge.svg)
![CD Status](https://github.com/madabank/madabank-ios/actions/workflows/cd.yml/badge.svg)
![Language](https://img.shields.io/badge/language-Swift-orange.svg)
![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)


## Overview
The **Networking** module handles all API communications. It provides an abstraction over URLSession or other networking libraries.

## Features
- **Network Client**: Generic client for making requests.
- **Endpoints**: Definition of API endpoints.
- **Interceptors**: Authentication tokens, logging, etc.

## Dependencies
- `Shared/Core`
- `Shared/Domain` (for error types or entities if shared)

## Usage
Used by the **Shared/Data** module to fetch data from remote sources.
