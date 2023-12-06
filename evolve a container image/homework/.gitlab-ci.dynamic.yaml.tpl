evolve a container image:
  image: $CONTAINER_IMAGE_NAME
  script:
  - |
    sh /menu.sh > menu.output
    [ \"\$DISH\" -a \"\$DISH\" != \"stew\" ] \
      || (echo FAIL: Looks like you did not set DISH environment value; exit 1)
    cat menu.output
