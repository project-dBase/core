def generateKey(passw, jbmg, godina):
    temp = passw + jbmg + godina
    return temp


print(generateKey("password", "jbmg", "2020"))
