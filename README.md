# Hyprhaven - Wallpaper Setup Script

<!-- ![Hyprhaven Logo](https://placehold.it/1200x400) -->

## Overview

Hyprhaven is a Bash script designed to simplify the process of setting up wallpapers on your Linux system. It leverages the [Wallhaven API](https://wallhaven.cc/) to fetch and download wallpapers based on user-defined criteria. Whether you want a random wallpaper or have specific preferences, Hyprhaven has got you covered.

## Features

- Fetch and download wallpapers from Wallhaven API.
- Set random wallpapers from a local directory.
- Configure wallpaper parameters such as categories, purity, and search queries.
- Set a specific wallpaper using the file path.
- Automatically set wallpapers using the [Hyprpaper](https://github.com/hyprwm/hyprpaper) wallpaper manager.

## Prerequisites

- Bash (Unix shell)
- [Hyprpaper](https://github.com/hyprwm/hyprpaper) - Wallpaper manager
- Wallhaven API key (optional, for accessing NSFW images)

## Getting Started

1. Clone the repository:

```sh
git clone https://github.com/your-username/hyprhaven.git
cd hyprhaven
```

2. Make the script executable:

```bash
chmod +x hyprhaven.sh
```

3. Run the script with appropriate options:

```sh
./hyprhaven.sh -r   # Set a random wallpaper
./hyprhaven.sh -d   # Fetch and download wallpapers from Wallhaven
./hyprhaven.sh -c "general, anime" -p "sfw" -q "landscape"  # Customize wallpaper search
```

Enjoy your personalized wallpapers!

## Options
| Option | Description|
|--------|------------|
|-r| Set a random wallpaper from the local directory.|
|-d| Fetch and download wallpapers from Wallhaven based on specified criteria.|
|-c CATEGORY| Specify wallpaper categories (e.g., "general, anime").|
|-p PURITY| Specify wallpaper purity (e.g., "sfw, nsfw").|
|-q QUERY| Specify a search query for wallpapers.|
|-s FILE_PATH| Set a specific wallpaper using the provided file path.|

## Configuration

Edit the script to set your Wallhaven API key (API_KEY variable).
Adjust other constants such as WALLPAPER_DIR, MIN_RES, and PERMITTED_RATIO as needed.

## License

This project is licensed under the [MIT License](https://github.com/vivalchemy/hyprhaven/blob/main/LICENSE).

## Acknowledgments

Hyprhaven is inspired by the [Hyprwm](https://github.com/hyprwm/) project.

## Contributing

Contributions are welcome! 

## Contact

For any inquiries or issues, please open an issue.
