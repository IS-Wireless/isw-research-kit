Handler for file type TYPE shall provide following functions:
- is_TYPE: shall return lowercased string "TYPE" and 0 if given file is of type
           TYPE, or shall return 1 and no other output - if not
- TYPE_parser: shall output plain text representation of given INPUT file of
               type TYPE into given OUTPUT text file
- TYPE_pagecount: shall output number of pages of given INPUT file of type TYPE
- TYPE_requirements: shall output string white space-separated list of
                     apt-gettable packages helpful in converting type TYPE to
                     plain text.
