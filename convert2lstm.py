import os, sys, getopt

def main(argv):
   set_name = ''
   relative_path = ''
   psm_mode = 7
   dry_run = False

   

   try:
      opts, args = getopt.getopt(argv,"hn:i:p:d:")
   except getopt.GetoptError:
      print ('convert2lstm.py -n <set_name> -i <input folder> -p <psm mode> [-d]')
      sys.exit(2)

   for opt, arg in opts:
      if opt == '-h':
         print ('convert2lstm.py -n <set_name> -i <input folder> -p <psm mode> [-d]')
         sys.exit()
      elif opt in ("-n", "--name"):
         set_name = arg
      elif opt in ("-i", "--input"):
         relative_path = arg
      elif opt in ("-p", "--psm"):
         psm_mode = int(arg)
      elif opt in ("-d", "--dry"):
         dry_run = bool(int(arg))

   return set_name, relative_path, psm_mode, dry_run


if __name__ == "__main__":
   
   if len(sys.argv[1:])<2:
      print ('convert2lstm.py -n <set_name> -i <input folder> -p <psm mode> [-d]')
      sys.exit()


   set_name, relative_path, psm_mode, dry_run = main(sys.argv[1:])


   current_path = os.getcwd()
    
   os.chdir(relative_path)

   if dry_run:
      print('Only generating the train/eval file.')
      
   sample_names = os.listdir('.')

   sample_names = [sample_name.split('.')[0] for sample_name in sample_names]
   sample_names = list(set(sample_names))

   text_file = open(os.path.join(current_path, set_name+'.txt'), 'w')

   for name in sample_names:
      if not dry_run:
         print(name)
         cmd = 'tesseract --psm %d %s.tiff %s lstm.train'%(psm_mode, name,name)
         os.system(cmd)
      
      text_file.write(os.path.join(relative_path, '%s.lstmf'%name)+'\n')

   text_file.close()

