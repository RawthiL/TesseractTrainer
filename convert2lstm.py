import os, sys, getopt
import subprocess

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


   print('Creating set: %s'%set_name)

   current_path = os.getcwd()
    
   os.chdir(relative_path)

   if dry_run:
      print('Only generating the train/eval file.')
      
   sample_names = os.listdir('.')
   sample_names.sort()

   # Get list of existing ".lstmf" files
   lstmf_list = list()
   for this_file in sample_names:
      if this_file.endswith(".lstmf"):
         lstmf_list.append(this_file)

   sample_names = [sample_name.split('.')[0] for sample_name in sample_names]
   sample_names = list(set(sample_names))
   sample_names.sort()

   text_file = open(os.path.join(current_path, set_name+'.txt'), 'w')
   count_ok = 0
   count_partial = 0
   count_fail = 0

   if not dry_run:

      # Delete old lstmf files
      for this_file in lstmf_list:
         os.remove(this_file) 

      for name in sample_names:

         # Create lstmf file
         output_conv = subprocess.run(['tesseract', '--psm', '%d'%psm_mode, '%s.tiff'%name, name,  'lstm.train'], capture_output=True, text=True)

         # Check for error
         if 'Error' in output_conv.stderr:
            print('---------------------------------')         
            print('ERROR: Failed sample %s'%name)
            print(output_conv.stderr)
            print('---------------------------------')       
            count_fail += 1
         # If no error add to list            
         else: 
            count_ok += 1 
            text_file.write(os.path.join(relative_path, '%s.lstmf'%name)+'\n')
            # Inform missing lines
            if 'No block overlapping textline' in output_conv.stderr:
               print('---------------------------------')         
               print('WARNING: Some elements lost in sample %s'%name)
               print(output_conv.stderr)
               print('---------------------------------')       
               count_partial += 1
   else:
      # Only add existing lstmf files to list
      for this_file in lstmf_list:
         # read .lstmf files to generate .txt
         if os.path.exists(this_file): # Double check
               text_file.write(os.path.join(relative_path, this_file)+'\n')
               count_ok += 1
   text_file.close()

   if not dry_run:
      print('Created %d samples (%d samples partially recovered). Discarded %d samples.'%(count_ok,count_partial,count_fail))
   else:
      print('Found %d samples.'%(count_ok))
