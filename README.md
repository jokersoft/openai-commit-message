# Automation of git commit message
By using OpenAI capabilities
(with support of conventional commits)


## Installation

### Prerequisites
- Python 3+
- `pip install --upgrade openai` - to install [OpenAI Python Library](https://github.com/openai/openai-python)
- `export OPENAI_API_KEY='sk-...` to configure your OpenAI API key as an env var 

### Prepare for usage
#### Optional
Copy file to global scope and create alias:
```shell
cp ./git-aicommit.py /usr/local/bin/
echo 'alias git-aicommit="python /usr/local/bin/git-aicommit.py"' >> ~/.bashrc 
```

### Usage

#### With alias:
```shell
git add .
git-aicommit
git push
```

#### Without alias:
```shell
git add .
python /path/to/git-aicommit.py
git push
```
