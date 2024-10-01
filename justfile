# Recipes
@default:
    just --list

decrypt:
    ansible-vault decrypt vars/vault.yml

encrypt:
    ansible-vault encrypt vars/vault.yml

dockerbox:
    ansible-playbook docker_services.yml
