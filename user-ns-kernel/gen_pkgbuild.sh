BASE_PACKAGE="core/linux"
CONTRIBUTOR="Roman Rader <antigluk@gmail.com>"

echo "====> Generating Linux kernel PKGBUILD based on ${BASE_PACKAGE} package that has CONFIG_USER_NS enabled" | tee -a gen_pkgbuild.log
echo "`date`" | tee -a gen_pkgbuild.log
echo "===> Retrieving ${BASE_PACKAGE}" | tee -a gen_pkgbuild.log

if [ -e ${BASE_PACKAGE} ]
	then
	echo "[WARNING] ${BASE_PACKAGE} already exist. Directory will be removed." | tee -a gen_pkgbuild.log
	rm -rf ${BASE_PACKAGE}
fi
ABSROOT=. abs ${BASE_PACKAGE} >> gen_pkgbuild.log

echo >> gen_pkgbuild.log
echo >> gen_pkgbuild.log

function patch() {
	echo "===> Patching ${1} to add CONFIG_USER_NS=y line" | tee -a gen_pkgbuild.log
	sed -i "s/# CONFIG_USER_NS is not set/CONFIG_USER_NS=y/g" ${1}
}

patch "${BASE_PACKAGE}/config"
patch "${BASE_PACKAGE}/config.x86_64"

echo "===> Patching PKGBUILD" | tee -a gen_pkgbuild.log
echo "==> Package name"
sed -i 's/^pkgbase=linux.*$/pkgbase=linux-user-ns-enabled/' ${BASE_PACKAGE}/PKGBUILD
echo "==> Contributor line"
sed -i '2i# Contributor: ${CONTRIBUTOR}' ${BASE_PACKAGE}/PKGBUILD
echo "==> Package description"
sed -i 's/^  pkgdesc="The \${pkgbase\/linux\/Linux} kernel and modules"$/  pkgdesc="The ${pkgbase\/linux\/Linux} kernel and modules with CONFIG_USER_NS enabled"/g' ${BASE_PACKAGE}/PKGBUILD

echo "===> Updating checksums" | tee -a gen_pkgbuild.log
(
	cd ${BASE_PACKAGE}
	updpkgsums
)

echo "===> makepkg --source" | tee -a gen_pkgbuild.log
(
	cd ${BASE_PACKAGE}
	makepkg --source
)

echo "===> ALL *.src.tar.gz WILL BE REMOVED" | tee -a gen_pkgbuild.log
rm -f *.src.tar.gz
mv "${BASE_PACKAGE}"/*.src.tar.gz ./

tar xf linux-user-ns-enabled-4.0.5-1.src.tar.gz linux-user-ns-enabled -C aur4
