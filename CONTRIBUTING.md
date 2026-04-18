# Contributing to RoadSOS

Welcome! We are thrilled you want to contribute to RoadSOS. This document is a guide to getting your local environment set up, understanding our architecture, and successfully merging your PRs.

## 1. Getting Started

Run the bootstrap script to verify your local setup:
```bash
./scripts/bootstrap.sh
```

## 2. Branching Strategy

We use **Trunk-Based Development**.
- All development happens in short-lived feature branches branching from `main`.
- Branch naming convention: `type/issue-number-short-description` (e.g., `feat/123-add-crash-sensor`, `fix/456-map-crash`).

## 3. Pull Requests

- Every PR requires at least 1 approval from a CODEOWNER.
- CI must pass (Linting, Tests, Build Verification).
- Commits must follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

## 4. Architecture Standards

RoadSOS uses a Feature-Driven Development (FDD) architecture. Do not add logic to the root `lib/` directory. Place new domains in `lib/features/` and strictly respect dependency boundaries (features cannot depend on other features directly).
