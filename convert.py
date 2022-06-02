import sys
import xml.etree.ElementTree as ET

def build_nickel(xml_root):
  if xml_root.find("template") != None:
  return f"""
  to_builder_xml {
    {map }
  }
  """
  # TODO

tree = ET.parse(sys.argv[1])
root = tree.getroot()

print(build_nickel(root))

