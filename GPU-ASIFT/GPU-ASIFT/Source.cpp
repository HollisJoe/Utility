#include "Header.h"
extern siftParam sift_gen_param;

void initialize() {
	sift_gen_param.set_from_file();
	//	sift_gen_param.pysize = 4000;
	if (initGPU_detector() == 0)
		cout << "GPUSift Initialization Failed ..." << endl;
}

Mat get_affine(float angle, float rr, float tt) {
	angle *= -1;
	rr *= PI / 180.0F;
	float cos_psi = cosf(angle), sin_psi = sinf(angle), cos_phi = cosf(rr), sin_phi = sinf(rr);

	Mat Aff(2, 2, CV_32FC1);
	float *aff = (float *)Aff.data;
	aff[0] = cos_psi*tt*cos_phi - sin_psi*sin_phi;
	aff[1] = cos_psi*tt*(-sin_phi) - sin_psi*cos_phi;
	aff[2] = sin_psi*tt*cos_phi + cos_psi*sin_phi;
	aff[3] = sin_psi*tt*(-sin_phi) + cos_psi*cos_phi;

	return Aff;
}

Mat get_transformation(Mat &af1, Mat &af2) {
	Mat T = af1.inv() * af2;
	T /= norm(T, NORM_L2);
	return T;
}

void extractASIFT(Mat &gray, vector<KeyPoint> &kpt, vector<Mat> &aff, Mat& d) {
	asift_image_float im;
	Mat imgf(gray.size(), CV_32FC1);
	gray.convertTo(imgf, CV_32FC1);

	im.data = (float *)imgf.data;
	im.width = gray.cols;
	im.height = gray.rows;

	vector<vector<keypointslist>> single_key;
	int keys = 0;
	detectAndcompute(im, &keys, sift_gen_param.num_tilt, single_key);

	kpt.resize(keys);
	aff.resize(keys);
	d.create(keys, 128, CV_32FC1);
	int idx = 0;
	for (int i = 0; i < single_key.size(); i++)
	{
		for (int j = 0; j < single_key[i].size(); j++)
		{
			for (int k = 0; k < single_key[i][j].size(); k++)
			{
				keypoint &p = single_key[i][j][k];
				kpt[idx].pt.x = p.x;
				kpt[idx].pt.y = p.y;
				kpt[idx].size = p.scale;
				kpt[idx].angle = p.angle;

				aff[idx] = get_affine(p.angle, p.rot, p.tilt);
				memcpy(d.ptr<float>(idx), &p.vec[0], 128 * sizeof(float));
				idx++;
			}
		}
	}
	assert(idx == keys);
}

// write sfm formate
typedef struct sift_fileheader_v2
{
	int	 szFeature;
	int  szVersion;
	int  npoint;
	int  nLocDim;
	int  nDesDim;
}sift_fileheader_v2;
void saveSIFTB2(const char* szFile, vector<KeyPoint> &kpt, Mat &des)
{
	int i, sift_eof = (0xff + ('E' << 8) + ('O' << 16) + ('F' << 24));
	sift_fileheader_v2 sfh;
	int fd = _open(szFile, _O_BINARY | _O_CREAT | _O_WRONLY | _O_TRUNC);
	if (fd<0) return;

	// head
	sfh.szFeature = ('S' + ('I' << 8) + ('F' << 16) + ('T' << 24));
	sfh.szVersion = ('V' + ('4' << 8) + ('.' << 16) + ('0' << 24));
	sfh.npoint = kpt.size();
	sfh.nLocDim = 5;
	sfh.nDesDim = 128;
	_write(fd, &sfh, sizeof(sfh));

	// write keypoint
	float* fph;
	float* fp;
	fph = new float[sfh.npoint*sfh.nLocDim];
	fp = fph;
	// x y scale angle
	for (i = 0; i < sfh.npoint; i++)
	{
		*fp++ = kpt[i].pt.x;
		*fp++ = kpt[i].pt.y;
		*fp++ = kpt[i].size;
		*fp++ = kpt[i].angle;
		*fp++ = 0.0f;
	}
	_write(fd, fph, sizeof(float)*sfh.npoint*sfh.nLocDim);

	//write descriptor
	_write(fd, des.data, sizeof(float)*des.rows * des.cols);
	_write(fd, &sift_eof, sizeof(int));
	_close(fd);
}
void loadSIFTB2(const char* szFile, vector<KeyPoint> &kpt, Mat &des)
{
	int name, version, npoint, nLocDim, nDesDim, sift_eof, sorted = 0;
	int fd = _open(szFile, _O_BINARY | _O_RDONLY);
	if (fd<0) return;
	///
	_read(fd, &name, sizeof(int));
	_read(fd, &version, sizeof(int));

	//version 2 file
	_read(fd, &npoint, sizeof(int));
	_read(fd, &nLocDim, sizeof(int));
	_read(fd, &nDesDim, sizeof(int));

	kpt.resize(npoint);
	des.create(npoint, 128, CV_32FC1);

	float *locData = new float[nLocDim *npoint];
	if (npoint>0 && nLocDim == 5 && nDesDim == 128)
	{
		_read(fd, locData, nLocDim *npoint * sizeof(float));
		_read(fd, des.data, nDesDim*npoint * sizeof(float));

		for (size_t i = 0; i < npoint; i++)
		{
			kpt[i].pt.x = locData[0];
			kpt[i].pt.y = locData[1];
			kpt[i].size = locData[2];
			kpt[i].angle = locData[3];

			locData += nLocDim;
		}

		_read(fd, &sift_eof, sizeof(int));
		_close(fd);
	}
	else
	{
		_close(fd);
		cout << "load feature error" << endl;
	}
}
void saveAffineB2(string filename, vector<Mat> &Aff) {
	ofstream ofs(filename, std::ofstream::out);
	int numImgs = Aff.size();
	ofs << numImgs << endl;
	for (int i = 0; i < numImgs; i++)
	{
		ofs << Aff[i].at<float>(0, 0) << " ";
		ofs << Aff[i].at<float>(0, 1) << " ";
		ofs << Aff[i].at<float>(1, 0) << " ";
		ofs << Aff[i].at<float>(1, 1) << endl;
	}
	ofs.close();
}
void loadAffineB2(string filename, vector<Mat> &Aff) {
	ifstream ifs;
	ifs.open(filename);
	int numImgs;
	ifs >> numImgs;
	Aff.resize(numImgs);
	for (int i = 0; i < numImgs; i++)
	{
		Aff[i].create(2, 2, CV_32FC1);
		ifs >> Aff[i].at<float>(0, 0);
		ifs >> Aff[i].at<float>(0, 1);
		ifs >> Aff[i].at<float>(1, 0);
		ifs >> Aff[i].at<float>(1, 1);
	}
	ifs.close();
}

void RatioMatch(Mat &d1, Mat &d2, vector<DMatch> &matches, vector<DMatch> &matches_ratio) {
	FlannBasedMatcher matcher;
	vector<vector<DMatch>> tempMatches;
	matcher.knnMatch(d1, d2, tempMatches, 2);

	matches.resize(tempMatches.size());
	matches_ratio.reserve(tempMatches.size());

	for (size_t i = 0; i < tempMatches.size(); i++)
	{
		matches[i] = tempMatches[i][0];

		if (tempMatches[i][0].distance / tempMatches[i][1].distance < 0.66)
		{
			matches_ratio.push_back(tempMatches[i][0]);
		}
	}
}
Mat DrawInlier(Mat &src1, Mat &src2, vector<KeyPoint> &kpt1, vector<KeyPoint> &kpt2, vector<DMatch> &inlier, int type) {
	const int height = max(src1.rows, src2.rows);
	const int width = src1.cols + src2.cols;
	Mat output(height, width, CV_8UC3, Scalar(0, 0, 0));
	src1.copyTo(output(Rect(0, 0, src1.cols, src1.rows)));
	src2.copyTo(output(Rect(src1.cols, 0, src2.cols, src2.rows)));

	if (type == 1)
	{
		for (size_t i = 0; i < inlier.size(); i++)
		{
			Point2f left = kpt1[inlier[i].queryIdx].pt;
			Point2f right = (kpt2[inlier[i].trainIdx].pt + Point2f((float)src1.cols, 0.f));
			line(output, left, right, Scalar(0, 255, 255));
		}
	}
	else if (type == 2)
	{
		for (size_t i = 0; i < inlier.size(); i++)
		{
			Point2f left = kpt1[inlier[i].queryIdx].pt;
			Point2f right = (kpt2[inlier[i].trainIdx].pt + Point2f((float)src1.cols, 0.f));
			line(output, left, right, Scalar(255, 0, 0));
		}

		for (size_t i = 0; i < inlier.size(); i++)
		{
			Point2f left = kpt1[inlier[i].queryIdx].pt;
			Point2f right = (kpt2[inlier[i].trainIdx].pt + Point2f((float)src1.cols, 0.f));
			circle(output, left, 1, Scalar(0, 255, 255), 2);
			circle(output, right, 1, Scalar(0, 255, 0), 2);
		}
	}


	return output;
}

void runImgList(string imageList) {
	// get image names
	vector<string> ImgNames;
	ifstream ifs;
	ifs.open(imageList);
	string tmp;
	while (ifs.good())
	{
		ifs >> tmp;
		ImgNames.push_back(tmp);
	}
	ifs.close();
	//	cout << ImgNames.size() << endl;
	//	cout << ImgNames[0] << endl;

	// run ImageList
	initialize();

	const int numImgs = ImgNames.size();
	vector<KeyPoint> kpt;
	vector<Mat> aff;
	Mat descriptor;
	for (int i = 0; i < numImgs; i++)
	{
		Mat img_gray = imread(ImgNames[i], 0);
		extractASIFT(img_gray, kpt, aff, descriptor);

		string siftname = ImgNames[i].substr(0, ImgNames[i].find_first_of(".")) + ".sift";
		string affName = ImgNames[i].substr(0, ImgNames[i].find_first_of(".")) + ".aff";

		saveSIFTB2(siftname.c_str(), kpt, descriptor);
		saveAffineB2(affName, aff);
	}

}

void testImglist(string imageList) {
	// get image names
	vector<string> ImgNames;
	ifstream ifs;
	ifs.open(imageList);
	string tmp;
	while (ifs.good())
	{
		ifs >> tmp;
		ImgNames.push_back(tmp);
	}
	ifs.close();


	// read paramter
	const int numImgs = ImgNames.size();
	vector<KeyPoint> kpt1, kpt2;
	vector<Mat> aff1, aff2;
	Mat d1, d2;

	Mat img1 = imread(ImgNames[0]);
	Mat img2 = imread(ImgNames[1]);

	cout << "ok here" << endl;
	string siftname = ImgNames[0].substr(0, ImgNames[0].find_first_of(".")) + ".sift";
	string affName = ImgNames[0].substr(0, ImgNames[0].find_first_of(".")) + ".aff";
	loadSIFTB2(siftname.c_str(), kpt1, d1);
	loadAffineB2(affName, aff1);

	siftname = ImgNames[1].substr(0, ImgNames[1].find_first_of(".")) + ".sift";
	affName = ImgNames[1].substr(0, ImgNames[1].find_first_of(".")) + ".aff";
	loadSIFTB2(siftname.c_str(), kpt2, d2);
	loadAffineB2(affName, aff2);

	//
	vector<DMatch> matches, matches_ratio;
	RatioMatch(d1, d2, matches, matches_ratio);

	//// DRAW
	Mat draw = DrawInlier(img1, img2, kpt1, kpt2, matches_ratio, 1);
	imshow("show", draw);
	waitKey();
}


void example() {
	initialize();

	Mat img1 = imread("D:/data/04.jpg");
	Mat img2 = imread("D:/data/05.jpg");

	Mat gray1, gray2;
	cvtColor(img1, gray1, CV_BGR2GRAY);
	cvtColor(img2, gray2, CV_BGR2GRAY);

	vector<KeyPoint> kp1, kp2;
	Mat d1, d2;
	vector<Mat> aff1, aff2;
	vector<DMatch> matches, matches_ratio;

	// GPU-ASIFT
	extractASIFT(gray1, kp1, aff1, d1);
	extractASIFT(gray2, kp2, aff2, d2);

	// MATCH
	clock_t bg, ed;
	bg = clock();
	RatioMatch(d1, d2, matches, matches_ratio);
	ed = clock();
	cout << "flann match time : " << (ed - bg) << " ms" << endl;

	//// DRAW
	Mat draw = DrawInlier(img1, img2, kp1, kp2, matches_ratio, 1);
	imshow("show", draw);
	waitKey();

}


int main() {
	
	example();

//	string ImgList = "D:/data/image_list.txt";
//	runImgList(ImgList);
//	testImglist(ImgList);

}


