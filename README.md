# SmartCampusMaua Open-Source Docs

*See `_Template` to see how to create a new `doc`.*
*Recommended use with [Obsidian](https://obsidian.md/download) and [Excalidraw Plugin](https://github.com/zsviczian/obsidian-excalidraw-plugin).*


- Clone this Github Repository to local files:
``` bash
git clone https://github.com/SmartCampusMaua/Docs
```

- Checkout to a new local branch:
```bash
git checkout -b feature/NAME_OF_NEW_FEATURE
```

- *Create new Things!*

- Add new things to the created branch:
```bash
git add .
git commit -m "add NAME_OF_NEW_FEATURE"
git push origin feature/NAME_OF_NEW_FEATURE
```

- Create a Pull Request in Github
- Delete the Branch in Github

- Update local `develop` branch:
```bash
git checkout -b develop
git pull origin develop
```

- Remove the `feature/NAME_OF_NEW_FEATURE` branch
```bash
git branch -d feature/NAME_OF_NEW_FEATURE
```