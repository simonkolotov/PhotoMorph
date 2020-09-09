# import the necessary packages
from imutils import face_utils
import numpy as np
import argparse
import imutils
import dlib
import cv2
import colorsys

class FaceSelector(object):
  """
  Selects a single face in an image based on a user input
  """

  def __init__(self, image, downsampleWidth = 500):
    """
    Arguments:
    - `image`: the image in cv2 format
    - `downsampleWidth`: the width of image to downsample to if needed [500]
    """
    self.image = image

    # initialize dlib's face detector (HOG-based) and then create
    self.detector = dlib.get_frontal_face_detector()

    self.downsampleWidth = downsampleWidth

    try:
      self.DetectFace(self.image)
    except:
      #try another size?
      img500 = imutils.resize(self.image.copy(), width=self.downsampleWidth)
      r = float(self.image.shape[1]) / self.downsampleWidth

      self.DetectFace(img500)

      #don't forget to upsample back
      self.face = dlib.rectangle(int(self.face.left()  *r),
                                 int(self.face.top()   *r),
                                 int(self.face.right() *r),
                                 int(self.face.bottom()*r))

  def DetectFace(self, img):
    """
    Detect all faces in the image
    """

    #convert to grayscale
    grayImg = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # detect faces in the grayscale image
    faces = self.detector(grayImg, 1)

    if len(faces) == 0:
      raise Exception("No Faces Detected!") #TODO: Face Selection?

    elif len(faces) > 1:
      self.SelectSingleFace(img,faces)

      if self.face == None:
        raise Exception("No Face Selected!") #TODO: Skip photo

    else:
      self.face = faces[0]

  def SelectSingleFace(self, img, faces, downsampleWidth = None):
    """
    Select a single face out of all the ones available

    Arguments:
    - `faces`: the recognized rects of faces
    - `downsampleWidth`: the width of downsampled image to present if needed
    """
    #downsample the image for easier picking
    if downsampleWidth is None:
      downsampleWidth = self.downsampleWidth
    self.img500 = imutils.resize(img.copy(), width=downsampleWidth)

    #resizing ratio
    r = downsampleWidth / float(img.shape[1])

    #show downsampled image
    self.faceSelectionWin = "Select a Face";
    cv2.namedWindow(self.faceSelectionWin)

    self.rects = []
    for (rectId,rect) in enumerate(faces):

      # convert dlib's rectangle to a OpenCV-style bounding box
      # i.e., (x, y, w, h), remember to downsize the coordinates
      self.rects += [tuple([int(i*r) for i in face_utils.rect_to_bb(rect)])]

      cv2.putText(self.img500, "RET/SPC to select, q/ESC to quit", (10, 30), cv2.FONT_HERSHEY_SIMPLEX,
                  0.7, (0, 0, 255), 2)

    # create trackbar for face selection
    cv2.createTrackbar('Select a face',           #Title
                       self.faceSelectionWin,      #Window
                       1,                         #Selected Value
                       len(faces),                #Limits
                       self.UpdateRectColors) #Callback

    self.UpdateRectColors(1) #select the first face in the image

    # ESC key or selection to exit
    while (1):
      pressedKey=cv2.waitKey(20)

      if pressedKey in (113, 27):   #'q' or esc
        self.face = None
        return

      elif pressedKey in (13, 32): #enter, space
        selectedFace = cv2.getTrackbarPos('Select a face',self.faceSelectionWin)-1

        self.face = faces[selectedFace] if selectedFace >= 0 else None
        return

      elif pressedKey in (82, 83, 151, 152): #up/right
        cv2.setTrackbarPos('Select a face',self.faceSelectionWin,
                         cv2.getTrackbarPos('Select a face',self.faceSelectionWin)+1)

      elif pressedKey in (81, 84, 150, 153): #up/right
        cv2.setTrackbarPos('Select a face',self.faceSelectionWin,
                         cv2.getTrackbarPos('Select a face',self.faceSelectionWin)-1)

      elif pressedKey != -1:
        print ("Unknown key <{0}/{1}>".format(chr(pressedKey), pressedKey))

    cv2.destroyWindow(self.faceSelectionWin)

  #--- Utility functions ---
  def UpdateRectColors(self, selectedRectId):
    """
    Utility function for coloring selected face

    Arguments:
    - `selectedRectId`: the selected id of the face (1 based)
    """

    for (rectId, rect) in enumerate(self.rects):

      (x, y, w, h) = rect
      color = (0,255,0) if rectId == selectedRectId-1 else (0,0,255) #selection is 1 based

      cv2.rectangle(self.img500, (x, y), ((x + w), (y + h)), color, 2)

      # show the face number
      cv2.putText(self.img500,
                  "Face #{}".format(rectId + 1),
                  (x - 10, y - 10),
                  cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)

      cv2.imshow(self.faceSelectionWin, self.img500)

class ImageTriangulator(object):
  """
  Utility class doing Delaunay triangulation on interest points in an image
  """
  def __init__(self, image, points, trianglePoints = None, doPreviewTriangles = False):
    """
    Arguments:
    - `image`: the image (used for size and preview, maybe passing it is an overkill)
    - `points`: the list of points to triangulate
    - `doPreviewTriangles`: preview triangles colored in the image
    """
    self.points = points
    self.image = image

    #add image corners and mid-points for completeness
    size = image.shape
    self.points = np.append(self.points,np.array([[0,0],
                                                  [0,size[0]/2],
                                                  [0,size[0]-1],
                                                  [size[1]-1/2,size[0]-1],
                                                  [size[1]-1,size[0]-1],
                                                  [size[1]-1,size[0]/2],
                                                  [size[1]-1,0],
                                                  [size[1]-1/2,0]]),0)

    self.GenerateTriangles(trianglePoints)

    if doPreviewTriangles:
      self.PreviewTriangles()

  def GenerateTriangles(self, trianglePointIds = None):
    """
    Generate the list of triangle coordinates
    """

    #If no triangle point ids provided - perform Delaunay triangulation and save point ids
    if (type(trianglePointIds) == type(None)):
        self.TriangulatePoints()

        self.CalculateTrianglePointIds()

    #If points are provided - just calculate the corresponding coordinates
    else:
        self.trianglePointIds = trianglePointIds

        self.CalculateTriangleCoordinates()
        
      
  def TriangulatePoints(self):
    """
    perform Delaunay triangulation
    """
    size = self.image.shape
    subdiv = cv2.Subdiv2D((0, 0, size[1], size[0]))

    for i,point in enumerate(self.points):
      subdiv.insert(tuple(point))

    self.triangles = subdiv.getTriangleList().astype(int)

  def CalculateTrianglePointIds(self):
    """
    Translate triangles defined by coordinates into triangles defined by point ids
    """
    self.trianglePointIds = []
    
    #unfortunately it's probably simpler to do in O(n^3) than think of more elegant solutions
    #  given the relatively small number of points it's not an issue really
    for triangle in self.triangles: #all points in triangle
      pointIds = []
      for x,y in zip(triangle[0::2], triangle[1::2]): #all x,y coordinates of a point
        for pointId, point in enumerate(self.points):
          if (x == int(point[0]) and y == int(point[1])):
            pointIds += [pointId]
            break

      self.trianglePointIds += [pointIds]

  def CalculateTriangleCoordinates(self):
    """
    Translate triangles defined by point ids into triangles defined by coordinates
    """

    #numpy array [x, y, x, y, x, y]
    #There is probably a more pythonian way to write this, but what the hell

    
    triangles = []
    for triangle in self.trianglePointIds:
      triangleCoords = []
      for pointId in triangle:
        triangleCoords += [int(self.points[pointId][0]), int(self.points[pointId][1])]

      triangles += [triangleCoords]

    self.triangles = np.array(triangles)

  def PreviewTriangles(self):
    """
    Preview triangles colored in the image
    """
    #generate preview colors
    hsvColors = [[h,1,1] for h in np.linspace(0,1,len(self.triangles))]
    rgbColors = [[x*255 for x in colorsys.hsv_to_rgb(*c)] for c in hsvColors]
    bgrColors = [[b,g,r] for(r,g,b) in rgbColors]

    #make a copy of the image
    imgCopy = self.image.copy()

    for i,triangle in enumerate(self.triangles):

      pt1 = (triangle[0], triangle[1])
      pt2 = (triangle[2], triangle[3])
      pt3 = (triangle[4], triangle[5])

      cv2.line(imgCopy, pt1, pt2, bgrColors[i], 1, cv2.LINE_AA, 0)
      cv2.line(imgCopy, pt2, pt3, bgrColors[i], 1, cv2.LINE_AA, 0)
      cv2.line(imgCopy, pt3, pt1, bgrColors[i], 1, cv2.LINE_AA, 0)

    cv2.imshow("Triangles", imgCopy)
    cv2.waitKey(0)

class FaceLandmarkDetector(object):
  """
  Finds face landmars in an ROI of an image
  """

  def __init__(self, predictor, image, roi, doPreviewLandmarks = False):
    """
    Arguments:
    - `image`: the image in cv2 format
    - `roi`: the rectangle containing the selected face
    - `doPreviewLandmarks`: preview landmarks colored in the image
    """
    self.image = image
    self.roi = roi

    self.predictor = dlib.shape_predictor(predictor)

    self.DetectLandmarks()

    if doPreviewLandmarks:
      self.PreviewLandmarks()

  def DetectLandmarks(self):
    """
    Detect the face landmarks within a face ROI
    """
    #convert to grayscale (again?)
    grayImg = cv2.cvtColor(self.image, cv2.COLOR_BGR2GRAY)
    self.points = face_utils.shape_to_np(self.predictor(grayImg, self.roi))

  def PreviewLandmarks(self):
    """
    Preview the result of the facial landmark detection
    """
    output = face_utils.visualize_facial_landmarks(self.image, self.points)
    cv2.imshow("Landmarks", output)
    cv2.waitKey(0)


class FaceMorpher(object):
  """
  Morphs Faces based on interest points
  """

  def __init__(self, image1, triangles1, image2, triangles2):
    """

    Arguments:
    - `image1`: first image
    - `points1`: list of interest points for image 1
    - `image2`: second image
    - `points2`: list of interest points for image 2
    - `triangles`: list of triangles from points above
    """

    #convert Mat to float data type
    self.image1 = np.float32(image1)
    self.image2 = np.float32(image2)
    self.triangles1 = triangles1
    self.triangles2 = triangles2

    #precalculate the size of the morphed image
    size1, size2 = image1.shape, image2.shape
    self.outputHeight, self.outputWidth = max(size1[0], size2[0]), max(size1[1], size2[1])

  def MorphFaces(self, morphDegree = 0.5):
    """
    Morph the faces within the given degree

    Arguments:
    - `morphDegree`: the degree the images are morphed, [0-1]
    """

    #Clear the output image
    self.morphedImage = np.zeros((self.outputHeight, self.outputWidth, 3),
                                 dtype = np.float32)

    # Morph one triangle at a time.
    for (triangle1, triangle2) in zip(self.triangles1, self.triangles2):
      self.MorphTriangle(triangle1, triangle2, morphDegree)

  def MorphTriangle(self, triangle1, triangle2, morphDegree):
    """
    Morph and alpha-blend triangular regions from images 1 and 2 into morphedImage.
    This is heavily based on Satya Malik's Face Morph code

    Arguments:
    -`triangle1`: triangle1 coordinates in numpy array [x, y, x, y, x, y]
    -`triangle2`: triangle2 coordinates in numpy array [x, y, x, y, x, y]
    -`morphDegree`: degree of morphing (for the final blending of edge image data)
    """

    #triangles
    triangleMorphed = np.array([(1-morphDegree)*a + morphDegree*b for (a,b) in zip(triangle1,triangle2)])

    #reshape the triangles to get coordinate pairs
    triangle1 = triangle1.reshape(3,2)
    triangle2 = triangle2.reshape(3,2)
    triangleMorphed = triangleMorphed.reshape(3,2)

    #bounding rectangles of each of the triangles
    boundingRect1 = cv2.boundingRect(triangle1)
    boundingRect2 = cv2.boundingRect(triangle2)
    boundingRectMorphed = cv2.boundingRect(triangleMorphed.astype(int))

    # Offset points by left top corner of the respective rectangles
    triangle1Rect = []
    triangle2Rect = []
    triangleMorphedRect = []

    for i in range(0, 3):
      triangle1Rect.append(((triangle1[i][0] - boundingRect1[0]),
                            (triangle1[i][1] - boundingRect1[1])))

      triangle2Rect.append(((triangle2[i][0] - boundingRect2[0]),
                            (triangle2[i][1] - boundingRect2[1])))

      triangleMorphedRect.append(((triangleMorphed[i][0] - boundingRectMorphed[0]),
                                  (triangleMorphed[i][1] - boundingRectMorphed[1])))


    # Get mask by filling triangle
    mask = np.zeros((boundingRectMorphed[3], boundingRectMorphed[2], 3), dtype = np.float32)
    cv2.fillConvexPoly(mask, np.int32(triangleMorphedRect), (1.0, 1.0, 1.0), 16, 0);

    # Apply warpImage to small rectangular patches
    img1Rect = self.image1[boundingRect1[1]:boundingRect1[1] + boundingRect1[3],
                           boundingRect1[0]:boundingRect1[0] + boundingRect1[2]]
    
    img2Rect = self.image2[boundingRect2[1]:boundingRect2[1] + boundingRect2[3],
                           boundingRect2[0]:boundingRect2[0] + boundingRect2[2]]

    size = (boundingRectMorphed[2], boundingRectMorphed[3])

    warpImage1 = self.ApplyAffineTransform(img1Rect, triangle1Rect, triangleMorphedRect, size)
    warpImage2 = self.ApplyAffineTransform(img2Rect, triangle2Rect, triangleMorphedRect, size)

    # Alpha blend rectangular patches
    imgRect = (1.0 - morphDegree) * warpImage1 + morphDegree * warpImage2

    # Copy triangular region of the rectangular patch to the output image
    self.morphedImage[boundingRectMorphed[1]:boundingRectMorphed[1]+boundingRectMorphed[3],
                      boundingRectMorphed[0]:boundingRectMorphed[0]+boundingRectMorphed[2]] = \
                        imgRect * mask +\
                        self.morphedImage[boundingRectMorphed[1]:boundingRectMorphed[1]+boundingRectMorphed[3],
                                          boundingRectMorphed[0]:boundingRectMorphed[0]+boundingRectMorphed[2]] * ( 1 - mask )


  def ApplyAffineTransform(self,
                           image,
                           sourceTriangle,
                           destTriangle,
                           size):
    """
    Apply affine transform calculated using srcTri and dstTri to src and
    output an image of size.
    """

    # Given a pair of triangles, find the affine transform.
    warpMat = cv2.getAffineTransform(np.float32(sourceTriangle), np.float32(destTriangle))
    
    # Apply the Affine Transform just found to the src image
    return cv2.warpAffine(image,
                          warpMat,
                          (size[0], size[1]),
                          None,
                          flags=cv2.INTER_LINEAR,
                          borderMode=cv2.BORDER_REFLECT_101)
    
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
if __name__ == '__main__':

  # construct the argument parser and parse the arguments
  ap = argparse.ArgumentParser()
  ap.add_argument("-p", "--shape-predictor", default='./res/shape_predictor_68_face_landmarks.dat',
                  help="path to facial landmark predictor")
  ap.add_argument("-i1", "--image1", required=True,
                  help="path to first input image")
  ap.add_argument("-i2", "--image2", required=True,
                  help="path to second input image")
  args = vars(ap.parse_args())

  image1 = cv2.imread(args["image1"])

  faceROI = FaceSelector(image1).face

  interestPoints1 = FaceLandmarkDetector(args["shape_predictor"],
                                        image1,
                                        faceROI, False).points

  triangulator = ImageTriangulator(image1, interestPoints1, None, False)
  triangles1 = triangulator.triangles
  trianglePointIds = triangulator.trianglePointIds

  #--------------
  image2 = cv2.imread(args["image2"])

  faceROI = FaceSelector(image2).face

  interestPoints2 = FaceLandmarkDetector(args["shape_predictor"],
                                        image2,
                                        faceROI, False).points

  triangles2 = ImageTriangulator(image2, interestPoints2, trianglePointIds, False).triangles
  #-------------

  faceMorpher = FaceMorpher(image1, triangles1,
                            image2, triangles2)


  for i in np.arange(0,1,0.05):
    faceMorpher.MorphFaces(i)
    morphedFace = faceMorpher.morphedImage
    cv2.imshow("Morphed", np.uint8(morphedFace))
    cv2.waitKey(1)
  """
  
  faceMorpher.MorphFaces(0.5)
  morphedFace = faceMorpher.morphedImage

  cv2.imshow("Morphed", np.uint8(morphedFace))
  cv2.waitKey(0)
"""