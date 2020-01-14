# ESP32

On linux

    replcmd --host=192.168.4.1 -p 1234 put boulder1024_lnk5768.bin boulder1024_lnk5768.bin

On ESP32

    import ps2recv
    import spiram

On linux

    ./linux_keyboard.py (edit IP address)
    bc<enter><enter><enter>

On ESP32

    spiram.load("boulder1024_lnk5768.bin",1024)

On ESP32

    lnk5768

