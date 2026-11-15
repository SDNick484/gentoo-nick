# Copyright 2024-25 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Trained model files for Howdy."
HOMEPAGE="https://github.com/davisking/dlib-models"
SRC_URI="https://github.com/davisking/dlib-models/archive/refs/tags/${PV//./-}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/dlib-models-${PV//./-}"
LICENSE="CC0-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

INSTALL_PATH=/usr/share/dlib-data/
MY_BINS=(
	"dlib_face_recognition_resnet_model_v1.dat"
	"mmod_human_face_detector.dat"
	"shape_predictor_5_face_landmarks.dat"
)

src_unpack() {
	default
	for f in "${MY_BINS[@]}"; do
		bunzip2 "${S}/${f}.bz2"
	done
}

src_install() {
	insinto "${INSTALL_PATH}"
	for f in "${MY_BINS[@]}"; do
		doins "${S}/${f}"
	done
}
