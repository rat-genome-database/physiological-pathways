package PPP_Services;

import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.datamodel.Gene;

import javax.servlet.ServletContext;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.Map;

/**
 * Created by IntelliJ IDEA.
 * User: WLiu
 * Date: Sep 1, 2010
 * Time: 12:52:51 PM
 * To change this template use File | Settings | File Templates.
 */
public class FileService {

    String name=new String();

//    final String resource_path = "c:\\PPP_resoures\\";
    final String resource_path = "/data/PPP_resources/";
    String img_lib_path = resource_path +  "imagelib/";
    String file_lib_path = resource_path + "filelib/";

    public FileService() {
        Map envMap = System.getProperties();

        // print the system environment variables
        for (Object key : envMap.keySet())
        {
            System.out.println(key + " = " +  envMap.get(key));
        }
     }

    public byte[] GetImage(String file_name, String image_type) {

        byte return_value[] = new byte[0];

        String image_format = file_name.toLowerCase();
        image_format = image_format.substring(image_format.lastIndexOf('.')+1, image_format.length());
        if (image_format.equals("svg")) {
            String svg_base = new String(img_lib_path + "SVG/");
            file_name = svg_base+file_name;
        } else if (image_format.equals("png")) {
            String svg_base = new String(img_lib_path + "PNG/");
            file_name = svg_base+file_name;
        } else if (image_format.equals("jpg")) {
            String svg_base = new String(img_lib_path + "JPEG/");
            file_name = svg_base+file_name;
        } else if (image_format.equals("swf")) {
            String svg_base = new String(img_lib_path + "SWF/");
              file_name = svg_base+file_name;
        } else if (image_format.equals("gif")) {
            String svg_base = new String(img_lib_path + "GIF/");
              file_name = svg_base+file_name;
          }
        System.out.println("Getting " + image_format + " image: [" + file_name + "] at " +
        file_name);

        try {
            File file= new File(file_name);
            FileInputStream fs = new FileInputStream(file);

            return_value = new byte[(int)file.length()];
            fs.read(return_value);

            fs.close();
        } catch (Exception e) {
            System.err.println(e.getStackTrace());
            e.printStackTrace();
        }

        System.out.println("Sending bytes: " + return_value.length);
      return return_value;
    }

    public byte[] GetFile(String file_name, String file_type) {

        byte return_value[] = new byte[0];

        System.out.println("Getting file: [" + file_name + "]");
        file_name = file_lib_path+file_name;

        try {
            File file= new File(file_name);
            FileInputStream fs = new FileInputStream(file);

            return_value = new byte[(int)file.length()];
            fs.read(return_value);

            fs.close();
        } catch (Exception e) {
            System.err.println(e.getStackTrace());
            e.printStackTrace();
        }

        System.out.println("Sending bytes: " + return_value.length);
      return return_value;
    }

    public byte[] SaveFile(String file_name, String file_type, byte[] data) {

        byte return_value[] = new byte[0];

        System.out.println("Saving file: [" + file_name + "]");
        file_name = file_lib_path+file_name;

        try {
            File file= new File(file_name);
            FileOutputStream fs = new FileOutputStream(file);

            fs.write(data);

            fs.close();
        } catch (Exception e) {
            System.err.println(e.getStackTrace());
            e.printStackTrace();
        }

        System.out.println("Getting bytes: " + data.length);
        return return_value;
    }

    public String GetGeneInfo(String gene_symbol, String options) {
        GeneDAO geneDAO = new GeneDAO();
//        Document doc = new DocumentImpl();
//        Element
        String xml_str = new String();
//        Element element = new Element();
        System.out.println("Retrieving Gene: [" + gene_symbol + "]");
        try {
            Gene gene = geneDAO.getGenesBySymbol(gene_symbol, 3);

            if (gene != null) {
                xml_str = "<gene symbol=\"" + gene_symbol
                        + "\" rgdID=\""
                        + gene.getRgdId()
                        + "\" description=\""
                        + gene.getDescription()
                        + "\" />";
            } else {
                xml_str = "<gene symbol=\""
                        + "\" rgdID=\""
                        + "-1"
                        + "\" description=\""
                        + "\" />";
            }

        } catch (Exception exception){

            exception.printStackTrace();
            return exception.getStackTrace().toString();

        }

        System.out.println("Gene XML: " + xml_str + "\n");
        return xml_str;
    }

    public byte[] GetFileList(String folderName, int mode){
//        String fileListName = folderName + "/__list__.xml";
//        byte[] fileList = GetFile(fileListName, "");
//        if (fileList.length > 0) return fileList;
//
//        // Create an empty list if the list doesn't exist
//        String fileContent = new String("<file_list></file_list>");
//        SaveFile(fileListName, "", fileContent.getBytes());
//        return fileContent.getBytes();

        File dir = new File(file_lib_path + folderName);
        File[] fileList = dir.listFiles();

        String fileContent = new String("<file_list>");
        if (fileList != null) {
            for (int i=0; i < fileList.length; i++) {
                switch (mode)
                {
                    case 0: // All files and folders
                    case 1: // Files only
                        if (fileList[i].isFile()) {
                            fileContent += ("<file name=\"" + fileList[i].getName()+"\" type=\"file\"/>");
                        }
                        if (mode == 1) break;
                    case 2: // Folders only
                        if (!fileList[i].isFile()) {
                            fileContent += ("<file name=\"" + fileList[i].getName()+"\" type=\"folder\"/>");
                        }
                        break;
                }
            }
        }
        fileContent += "</file_list>";
        return fileContent.getBytes();
    }

    public byte[] GetFileList(String folderName){
        return GetFileList(folderName, 1);
    }

    public byte[] GetFolderList(String folderName){
        return GetFileList(folderName, 2);
    }

    public String GetDiagramTitle() {
        return "test title";
    }

}
