# NebulaOS Architecture Overview

## Repository Structure
- docs/ contains build and product documentation
- scripts/ contains automation and build helpers
- themes/ contains UI theme concepts
- website/ contains a landing page prototype

## Build Flow
1. prepare the environment
2. install core packages
3. apply branding assets
4. build the ISO using archiso
5. test the resulting image

## Goals
- keep the project easy to expand
- separate documentation from implementation
- support future ISO and theme development
- support a full sci-fi experience with Chaotic-AUR and Yay integration
