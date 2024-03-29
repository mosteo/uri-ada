--  Configuration for uri_ada generated by Alire
pragma Restrictions (No_Elaboration_Code);

package Uri_Ada_Config is
   pragma Pure;

   Crate_Version : constant String := "1.1.0";
   Crate_Name : constant String := "uri_ada";

   Alire_Host_OS : constant String := "linux";

   Alire_Host_Arch : constant String := "x86_64";

   Alire_Host_Distro : constant String := "ubuntu";

   type Build_Profile_Kind is (release, validation, development);
   Build_Profile : constant Build_Profile_Kind := development;

end Uri_Ada_Config;
