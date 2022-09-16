# KissMP w/ VK-Framework
#### Important Note: The repositories linked below are currently closed source whilst in development. This will change in the future.

## Suggested Setup
1. Head over to [VK-Essentials](https://github.com/VK-Framework) and download the extensions you would like to use (Note: You need VK-Core)
2. Create a folder called `shared` and `servers` in a folder of your choice.
3. Create a folder in `shared` called `addons` and copy the `vk-core` folder into it (along with any other extensions you downloaded into `vk-score/extensions`)
4. Create a folder in `shared` called `vklib_libs` and copy the libraries from [here](https://github.com/vulcan-dev/vklib/releases) into it.
5. Create a folder in `servers`, name it whatever you want.

Create a file called `config.json` in the folder you just created and paste the contents from below.

`config.json`
```json
{
  "server_name": "My KissMP Server",
  "description": "My Server Description",
  "map": "/levels/smallgrid/info.json",
  "max_players": 15,
  "tickrate": 60,
  "port": 3698,
  "max_vehicles_per_client": 5,
  "show_in_server_list": true,
  "server_identifier": "AeMF%9`Hu4"
}
```

Create a file called `docker-compose.yml` in the folder you just created and paste the contents from below, customize to your liking.

`docker-compose.yml`
```yaml
version: "3"
services:
  kissmp:
    image: vk_kissmp-docker:latest
    ports:
      - "3698:3698/udp"
    restart: unless-stopped
    volumes:
      - ./:/server/
      - ./config.json:/server/config.json
      - ./mods/:/server/mods/
      - ../shared/addons/:/server/addons/
      - ../shared/addons/:/server/addons/
      - ../shared/vklib_libs/vklib.so:/server/vklib.so
      - ../shared/vklib_libs/libmongoc-1.0.so:/server/libmongoc-1.0.so
      - ../shared/vklib_libs/libbson-1.0.so:/server/libbson-1.0.so
    environment:
      MONGO_PASSWORD: YOUR_MONGO_PASSWORD
      MONGO_IP: YOUR_MONGO_IP
```