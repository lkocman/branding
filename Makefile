VERSION=tumbleweed
VERSION_NO_DOT=`echo ${VERSION} | sed 's:\.::g'`
THEME=openSUSE

all: info openSUSE.d

info:
	echo "Make sure to have rsvg-view and GraphicsMagick installed"

openSUSE.d: gfxboot.d gnome.d grub2.d icewm.d libreoffice.d wallpaper.d yast.d plymouth.d

openSUSE.d_clean:

CLEAN_DEPS+=openSUSE.d_clean

gfxboot.d:
	mkdir -p ~/.fonts openSUSE/gfxboot/data-boot/ openSUSE/gfxboot/data-install
	cp gfxboot/SourceSansPro-Light.ttf ~/.fonts
	for name in back welcome on off glow; do \
		rsvg-convert raw-theme-drop/$${name}.svg -w 800 -a -o tmp-$@.png; \
		gm convert -quality 100 -interlace None -colorspace YCbCr -geometry 800x600 -sampling-factor 2x2 tmp-$@.png openSUSE/gfxboot/data-install/$${name}.jpg; \
		rm tmp-$@.png; \
	done
	rsvg-convert gfxboot/text.svg -w 114 -a -o tmp-$@.png
	gm convert -quality 100 -interlace None -colorspace YCbCr -sampling-factor 2x2 tmp-$@.png openSUSE/gfxboot/data-install/text.jpg
	rm tmp-$@.png
	rsvg-convert raw-theme-drop/back.svg -w 800 -a -o tmp-$@.png
	gm convert -quality 100 -interlace None -colorspace YCbCr -geometry 800x600 -sampling-factor 2x2 tmp-$@.png openSUSE/gfxboot/data-boot/back.jpg
	rm tmp-$@.png
	rm ~/.fonts/SourceSansPro-Light.ttf

gfxboot.d_clean:
	rm -rf openSUSE/gfxboot

CLEAN_DEPS+=gfxboot.d_clean

gnome.d:
	mkdir -p openSUSE/gnome
	sed "s:@VERSION@:${VERSION}:g;s:@GNOME_STATIC_DYNAMIC@:static:g" gnome/wallpaper-branding-openSUSE.xml.in > openSUSE/gnome/wallpaper-branding-openSUSE.xml
	cp gnome/openSUSE-default-static.xml openSUSE/gnome/openSUSE-default-static.xml

gnome.d_clean:
	rm -rf openSUSE/gnome

CLEAN_DEPS+=gnome.d_clean

grub2.d:
	mkdir -p openSUSE/grub2
	cp -a boot/grub2/theme openSUSE/grub2/

grub2.d_clean:
	rm -rf openSUSE/grub2

CLEAN_DEPS+=grub2.d_clean

icewm.d:
	rm -rf openSUSE/icewm
	mkdir -p openSUSE/icewm
	cp -av icewm openSUSE/

icewm.d_clean:
	rm -rf openSUSE/icewm

CLEAN_DEPS+=icewm.d_clean

libreoffice.d:
	mkdir -p openSUSE/libreoffice/program
	cp -r libreoffice/flat_logo.svg libreoffice/sofficerc libreoffice/shell openSUSE/libreoffice/program/
	rsvg-convert libreoffice/intro.svg -o openSUSE/libreoffice/program/intro.png

libreoffice.d_clean:
	rm -rf openSUSE/libreoffice

CLEAN_DEPS+=libreoffice.d_clean

wallpaper.d:
	mkdir -p openSUSE/wallpapers openSUSE/wallpapers/openSUSEdefault/contents/images
	for size in 5120x3200 3840x2400 1280x1024 1600x1200 1920x1080 1920x1200 1350x1080 1440x1080; do \
		rsvg-convert raw-theme-drop/desktop-$${size}.svg -o openSUSE/wallpapers/openSUSEdefault/contents/images/$${size}.png; \
		optipng -o5 openSUSE/wallpapers/openSUSEdefault/contents/images/$${size}.png; \
	done
	for size in 1600x1200 1920x1200 1920x1080; do \
		cp wallpapers/default-$${size}.png.desktop openSUSE/wallpapers; \
		sed "s:@VERSION@:${VERSION}:g;s:@VERSION_NO_DOT@:${VERSION_NO_DOT}:g" wallpapers/openSUSE-$${size}.png.desktop.in > openSUSE/wallpapers/openSUSE${VERSION_NO_DOT}-$${size}.png.desktop; \
		ln -sf openSUSE${VERSION_NO_DOT}-$${size}.png openSUSE/wallpapers/default-$${size}.png; \
		ln -sf openSUSEdefault/contents/images/$${size}.png openSUSE/wallpapers/openSUSE${VERSION_NO_DOT}-$${size}.png; \
	done
	ln -s contents/images/1920x1200.png openSUSE/wallpapers/openSUSEdefault/screenshot.png
	cp -p kde-workspace/metadata.json openSUSE/wallpapers/openSUSEdefault/metadata.json

wallpaper.d_clean:
	rm -rf openSUSE/wallpapers

CLEAN_DEPS+=wallpaper.d_clean

yast.d:
#	create directly the background from the 4:3 root's blank background
	mkdir -p openSUSE/yast_wizard
	cp -a yast/* openSUSE/yast_wizard

yast.d_clean:
	rm -rf openSUSE/yast_wizard

CLEAN_DEPS+=yast.d_clean

plymouth.d:
	mkdir -p openSUSE/plymouth
	cp plymouth/config/plymouthd.defaults openSUSE/plymouth

plymouth.d_clean:
	rm -rf openSUSE/plymouth

CLEAN_DEPS+=plymouth.d_clean

install:
	# Wallpapers
	mkdir -p $(DESTDIR)/usr/share/wallpapers
	cp -a openSUSE/wallpapers/* ${DESTDIR}/usr/share/wallpapers
	install -D -m 0644 openSUSE/gnome/wallpaper-branding-openSUSE.xml ${DESTDIR}/usr/share/gnome-background-properties/wallpaper-branding-openSUSE.xml
	install -m 0644 openSUSE/gnome/openSUSE-default-static.xml ${DESTDIR}/usr/share/wallpapers/openSUSE-default-static.xml
	# Alternatives for default wallpapers
	mkdir -p ${DESTDIR}/etc/alternatives
	ln -sf /etc/alternatives/openSUSE-default.xml ${DESTDIR}/usr/share/wallpapers/openSUSE-default.xml
	ln -sf /usr/share/wallpapers/openSUSE-default-static.xml ${DESTDIR}/usr/share/wallpapers/openSUSE-default-dynamic.xml
	# YaST2 Qt theme
	mkdir -p $(DESTDIR)/usr/share/YaST2/theme/current
	cp -a openSUSE/yast_wizard ${DESTDIR}/usr/share/YaST2/theme/current/wizard
	ln -sf /usr/share/pixmaps/distribution-logos/light-dual-branding.svg ${DESTDIR}/usr/share/YaST2/theme/current/wizard/logo.svg
	# Grub2 theme
	mkdir -p $(DESTDIR)/usr/share/grub2/themes/${THEME} ${DESTDIR}/boot/grub2/themes/${THEME}
	cp -a openSUSE/grub2/theme/* ${DESTDIR}/usr/share/grub2/themes/${THEME}
	perl -pi -e "s/THEME_NAME/${THEME}/" ${DESTDIR}/usr/share/grub2/themes/${THEME}/activate-theme
	# Plymouth default config (jsc#SLE-11637)
	mkdir -p $(DESTDIR)/usr/share/plymouth/
	cp openSUSE/plymouth/plymouthd.defaults $(DESTDIR)/usr/share/plymouth
	# IceWM theme
	mkdir -p $(DESTDIR)/usr/share/icewm/themes/
	mkdir -p $(DESTDIR)/etc/icewm/
	install -m 0644 openSUSE/icewm/theme $(DESTDIR)/etc/icewm/
	cp -r openSUSE/icewm/themes/yast-installation/ $(DESTDIR)/usr/share/icewm/themes/
	# Libreoffice branding
	mkdir -p $(DESTDIR)/usr/share/libreoffice
	cp -r openSUSE/libreoffice/program $(DESTDIR)/usr/share/libreoffice
	# Brand file
	cp -r SUSE-brand $(DESTDIR)/etc/

clean: ${CLEAN_DEPS}
	rmdir openSUSE

check: # do not add requires here, this runs from generated openSUSE
	## Check GNOME-related xml files have contant that make sense
	# Check that the link for the dynamic wallpaper is valid
	LINK_TARGET=`readlink --canonicalize ${DESTDIR}/usr/share/wallpapers/openSUSE-default-dynamic.xml` ; \
	test -f "$${LINK_TARGET}" || { echo "The link for openSUSE-default-dynamic.xml is invalid. Please fix it, or contact the GNOME team for help."; exit 1 ;}
	# Check that all files referenced in xml files actually exist
	for xml in ${DESTDIR}/usr/share/wallpapers/openSUSE-default-static.xml ${DESTDIR}/usr/share/wallpapers/openSUSE-default-dynamic.xml; do \
	  xml_basename=`basename $${xml}` ; \
	  for file in `sed "s:<[^>]*>::g" $${xml} | grep /usr`; do \
	      test -f ${DESTDIR}/$${file} || { echo "$${file} is mentioned in $${xml_basename} but does not exist. Please update $${xml_basename}, or contact the GNOME team for help."; exit 1 ;} ; \
	  done ; \
	done
	# Check that xml files reference all relevant files
	for file in ${DESTDIR}/usr/share/wallpapers/openSUSEdefault/contents/images/*.jpg; do \
	   IMG=$${file#${DESTDIR}} ; \
	   grep -q $${IMG} ${DESTDIR}/usr/share/wallpapers/openSUSE-default-static.xml || { echo "$${IMG} not mentioned in openSUSE-default-static.xml. Please add it there, or contact the GNOME team for help." ; exit 1 ;} ; \
	done

