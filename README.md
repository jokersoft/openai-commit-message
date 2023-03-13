# Automation of git commit message
By using OpenAI capabilities
(with support of conventional commits)


## Installation

### Prerequisites
- Python 3+
- `pip install --upgrade openai` - to install [OpenAI Python Library](https://github.com/openai/openai-python)
- `export OPENAI_API_KEY='sk-...' to configure your OpenAI API key as an env var 

### Prepare for usage
Copy file to global scope and create alias:
```shell
cp ./git-aicommit.py /usr/local/bin/
echo 'alias git-aicommit="python /usr/local/bin/git-aicommit.py"' >> ~/.bashrc 
```

### Usage
```shell
git add .
python git-aicommit.py
git push
```