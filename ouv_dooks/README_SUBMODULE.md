# Gestion du sous-module Ouv Logic

## Pour récupérer les nouveautés du serveur :
`git submodule update --remote --force`

## Pour envoyer des modifications faites ici :
1. cd packages/ouv_logic
2. git add . && git commit -m "votre message"
3. git push origin main
4. cd ../..
5. git add packages/ouv_logic && git commit -m "sync logic"