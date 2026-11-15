# Copyright 2024-25 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="${PV//./-}"
# The three models howdy loads. The full dlib-models tag is ~200 MB;
# these are ~28 MB.
MY_BINS=(
	dlib_face_recognition_resnet_model_v1
	mmod_human_face_detector
	shape_predictor_5_face_landmarks
)

DESCRIPTION="Trained dlib face models used by Howdy"
HOMEPAGE="https://github.com/davisking/dlib-models"
for f in "${MY_BINS[@]}"; do
	SRC_URI+=" https://raw.githubusercontent.com/davisking/dlib-models/${MY_PV}/${f}.dat.bz2 -> ${P}-${f}.dat.bz2"
done
unset f
S="${WORKDIR}"
LICENSE="CC0-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

src_install() {
	insinto /usr/share/dlib-data
	local f
	for f in "${MY_BINS[@]}"; do
		newins "${P}-${f}.dat" "${f}.dat"
	done
}
