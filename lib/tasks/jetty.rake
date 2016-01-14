begin
  require 'jettywrapper'

  namespace :jetty do
    desc "Copies the application's solr config into jetty"
    task configure_solr: ['jetty:clean'] do
      FileList['solr_conf/conf/*'].each do |f|
        cp("#{f}", 'jetty/solr/blacklight-core/conf/', verbose: true)
      end

      cp_r('jetty/solr/blacklight-core', 'jetty/solr/blacklight-test', verbose: true)
    end
  end
rescue LoadError
  namespace :jetty do
    desc "Copies the application's solr config into jetty (requires jettywrapper)"
    task :configure_solr do
      # no-op
    end
  end
end
