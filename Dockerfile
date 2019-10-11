FROM electromatter/android-emulator:android-24

USER root
RUN mkdir /Users /Applications /Library /Volumes && \
	chown -R android:android /Users /Applications /Library /Volumes /usr/local
USER android
