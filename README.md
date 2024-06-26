# Lightshop
Lightshop is a web app that allows you to program and display light shows.
The target for lighting is a Raspberry Pi with WS281x lights.
This is actually the second edition of this software, with better ux and more features.

## Running
FYI: This project **REQUIRES** the bun runtime.
1. To run in production mode create a .env file in frontend that points to port 3000 on your server.
  - `VITE_TRPC=ws://localhost:3000/trpc`
  - (sidenote) The backend is expecting the build of frontend to be in `../frontend/build/` so you will have to change the hardcoded value in __index.ts__
2. Then inside the frontend run `bun i` and `bun run build`
3. Finally go to the backend folder and run `bun i`, `bun db:migrations`, and `bun run .`
