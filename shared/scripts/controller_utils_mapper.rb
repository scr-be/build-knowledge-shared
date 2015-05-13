$controller_methods = {
  'createForm' => 'createForm',
  'createNamedForm' => 'createNamedForm',
  'createNotFoundException' => 'getExceptionNotFound',
  'entityManagerFlush' => 'emFlush',
  'emPersist' => 'entityPersist',
  'emRemove' => 'entityRemove',
  # 'generateUrl' => ,
  'getParameter' => 'getParameter',
  'getSchemeAndHost' => 'getRequestSchemeAndHost',
  # 'getService' => ,
  # 'getServices' => ,
  'getTranslation' => 'getTranslation',
  'hasParameter' => 'hasParameter',
  'jsonResponse' => 'getResponseJSON',
  'plainTextResponse' => 'getResponseText',
  # 'redirectResponse' => ,
  # 'renderResponse' => ,
  # 'renderView' => ,
  # 'response' => ,
  'getResponseHTML' => 'getResponse',
  # 'routeRedirectResponse' => ,
  # 'sessionMessage' => ,
  'sessionMessageError' => 'addSessionMsgError',
  'sessionMessageInfo' => 'addSessionMsgInfo',
  'sessionMessageSuccess' => 'addSessionMsgSuccess',
}

def replace_methods(d, cont)
  $controller_methods.each do |old, new|
    puts cont + ': ' + old + ' -> ' + new
    #d.gsub!(/\$this->utils->#{old}/, "$this->#{new}")
    #d.gsub!(/\$this->utils->getService\(/, '$this->getService(')
    #d.gsub!(/\$this->getService\('em'\)/, '$this->em()')
    #d.gsub!(/\$this->getService\('session'\)/, '$this->session()')
    #d.gsub!(/\$this->getService\('user'\)/, '$this->user()')
    #d.gsub!(/\$this->getService\('security'\)/, '$this->getService(\'security.context\')')
  end
end

controller_loc = '{src,lib}/**/Controller/*.php'
controllers = Dir.glob(controller_loc)

controllers.each do |cont|
  d = File.read(cont)
  replace_methods(d, cont)
  File.open(cont, 'w') do |f|
    f.write(d)
  end
end