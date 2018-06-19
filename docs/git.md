### Fix "Upstream branch not stored as remote-tracking branch"

```
git remote add origin $(cat .git/config | grep 'remote =' | sed 's/.*= //'); git push -u origin master
```